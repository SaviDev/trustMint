import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../data/local/secure_storage.dart';
import '../../data/local/database/app_database.dart';

class HomeState {
  final String userId;
  final int totalRecordsSent;
  final String lastSync;
  final bool isUploading;
  final bool isCollecting;
  final Map<String, bool> permissions;

  HomeState({
    required this.userId,
    required this.totalRecordsSent,
    required this.lastSync,
    required this.isUploading,
    required this.isCollecting,
    required this.permissions,
  });

  HomeState copyWith({
    String? userId,
    int? totalRecordsSent,
    String? lastSync,
    bool? isUploading,
    bool? isCollecting,
    Map<String, bool>? permissions,
  }) => HomeState(
    userId: userId ?? this.userId,
    totalRecordsSent: totalRecordsSent ?? this.totalRecordsSent,
    lastSync: lastSync ?? this.lastSync,
    isUploading: isUploading ?? this.isUploading,
    isCollecting: isCollecting ?? this.isCollecting,
    permissions: permissions ?? this.permissions,
  );
}

class HomeController extends StateNotifier<HomeState> {
  final _storage = SecureStorage();
  final _db = dbInstance;
  Timer? _pollTimer;

  HomeController()
    : super(
        HomeState(
          userId: '',
          totalRecordsSent: 0,
          lastSync: 'Mai',
          isUploading: false,
          isCollecting: false,
          permissions: {
            'Sensori (Accel/Gyro/Mag)': false,
            'Notifiche': false,
            'Ottimizzazione batteria': false,
            'Attività fisica': false,
          },
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    // Load or create userId
    String? id = await _storage.getUserId();
    if (id == null) {
      id = const Uuid().v4();
      await _storage.saveUserId(id);
    }

    // Last sync label
    final lastSync = await _storage.read('last_sync') ?? 'Mai';

    // Real record count from DB
    final count = await _db.sensorDao.totalCount();

    // Check if background service is running
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    state = state.copyWith(
      userId: id,
      totalRecordsSent: count,
      lastSync: lastSync,
      isCollecting: isRunning,
    );

    // Poll DB every 5 seconds so the UI stays live while FGS writes data
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final freshCount = await _db.sensorDao.totalCount();
      final currentIsRunning = await service.isRunning();

      if (freshCount != state.totalRecordsSent ||
          currentIsRunning != state.isCollecting) {
        state = state.copyWith(
          totalRecordsSent: freshCount,
          isCollecting: currentIsRunning,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void updatePermission(String name, bool granted) async {
    final updated = Map<String, bool>.from(state.permissions);
    updated[name] = granted;
    state = state.copyWith(permissions: updated);

    // If all required permissions are granted, we can start the FGS
    if (updated.values.every((v) => v == true)) {
      final service = FlutterBackgroundService();
      if (!(await service.isRunning())) {
        await service.startService();
        state = state.copyWith(isCollecting: true);
      }
    }
  }

  /// Pause data collection by stopping the Foreground Service
  Future<void> pauseCollection() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
    state = state.copyWith(isCollecting: false);
  }

  /// Resume data collection by starting the Foreground Service
  Future<void> resumeCollection() async {
    // Only resume if permissions are still valid
    if (state.permissions.values.every((v) => v == true)) {
      final service = FlutterBackgroundService();
      if (!(await service.isRunning())) {
        await service.startService();
        state = state.copyWith(isCollecting: true);
      }
    }
  }

  /// Get current data summary from database
  Future<Map<String, int>> getSensorCounts() async {
    return await _db.sensorDao.getCountsPerType();
  }

  /// Get the last [limit] records for a specific [sensorType]
  Future<List<SensorData>> getLastRecords(
    String sensorType, {
    int limit = 10,
  }) async {
    return await _db.sensorDao.getLastRecords(sensorType, limit);
  }

  /// Generates 100 random sensor samples, inserts them to DB, then "uploads" them.
  Future<void> uploadRandomRecords() async {
    state = state.copyWith(isUploading: true);

    final random = Random();
    final sessionId = 'manual-${DateTime.now().millisecondsSinceEpoch}';

    final batch = List.generate(100, (i) {
      final type = ['accelerometer', 'gyroscope', 'magnetometer'][i % 3];
      return SensorDataTableCompanion.insert(
        userId: state.userId,
        sessionId: sessionId,
        sensorType: type,
        value: jsonEncode({
          'x': double.parse((random.nextDouble() * 20 - 10).toStringAsFixed(4)),
          'y': double.parse((random.nextDouble() * 20 - 10).toStringAsFixed(4)),
          'z': double.parse((random.nextDouble() * 20 - 10).toStringAsFixed(4)),
        }),
        timestamp: DateTime.now().subtract(Duration(seconds: 100 - i)),
      );
    });

    // Insert into local DB
    await _db.sensorDao.insertBatch(batch);

    // Simulate upload delay (replace with real HTTP call)
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final label =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} '
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
    await _storage.write('last_sync', label);

    final freshCount = await _db.sensorDao.totalCount();
    state = state.copyWith(
      isUploading: false,
      totalRecordsSent: freshCount,
      lastSync: label,
    );
  }
}

final homeProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});
