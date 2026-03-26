import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../data/local/secure_storage.dart';
import '../../data/local/database/app_database.dart';
import '../../data/chain/iota_constants.dart';

class HomeState {
  final String userId;
  final int totalRecordsSent;
  final String lastSync;
  final bool isUploading;
  final bool isCollecting;
  final Map<String, bool> permissions;
  final int pendingChunks;
  final String currentHash;

  HomeState({
    required this.userId,
    required this.totalRecordsSent,
    required this.lastSync,
    required this.isUploading,
    required this.isCollecting,
    required this.permissions,
    this.pendingChunks = 0,
    this.currentHash = '',
  });

  HomeState copyWith({
    String? userId,
    int? totalRecordsSent,
    String? lastSync,
    bool? isUploading,
    bool? isCollecting,
    Map<String, bool>? permissions,
    int? pendingChunks,
    String? currentHash,
  }) => HomeState(
    userId: userId ?? this.userId,
    totalRecordsSent: totalRecordsSent ?? this.totalRecordsSent,
    lastSync: lastSync ?? this.lastSync,
    isUploading: isUploading ?? this.isUploading,
    isCollecting: isCollecting ?? this.isCollecting,
    permissions: permissions ?? this.permissions,
    pendingChunks: pendingChunks ?? this.pendingChunks,
    currentHash: currentHash ?? this.currentHash,
  );
}

class HomeController extends StateNotifier<HomeState> {
  final _storage = SecureStorage();
  final _db = dbInstance;
  Timer? _pollTimer;
  final String bandoId;

  HomeController(this.bandoId)
    : super(
        HomeState(
          userId: '',
          totalRecordsSent: 0,
          lastSync: 'Never',
          isUploading: false,
          isCollecting: false,
          permissions: {
            'Sensors (Accel/Gyro/Mag)': false,
            'Notifications': false,
            'Battery Optimization': false,
            'Physical Activity': false,
          },
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    // We use the testnet user DID object instead of a random UUID
    String id = IotaChainConstants.defaultUserDidObjectId;

    // Last sync label
    final lastSync = await _storage.read('last_sync') ?? 'Never';

    // Real record count from DB
    final count = await _db.sensorDao.totalCount(bandoId);

    // Pending chunks count
    final pending = await _db.chunkDao.getPendingChunks();

    // Current rolling hash from active session
    final activeSession = await _db.sessionDao.getActiveSession();
    final currentHash = activeSession?.lastChunkHash ?? '';

    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    final isBandoActive = await _storage.read('active_$bandoId') == 'true';

    state = state.copyWith(
      userId: id,
      totalRecordsSent: count,
      lastSync: lastSync,
      isCollecting: isBandoActive && isRunning,
      pendingChunks: pending.length,
      currentHash: currentHash,
    );

    // Poll DB every 1 second so the UI stays live while FGS writes data
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final freshCount = await _db.sensorDao.totalCount(bandoId);
      final currentIsRunning = await service.isRunning();
      final currentIsActive = await _storage.read('active_$bandoId') == 'true';
      final nowCollecting = currentIsActive && currentIsRunning;

      final freshPending = await _db.chunkDao.getPendingChunks();
      final freshSession = await _db.sessionDao.getActiveSession();
      final freshHash = freshSession?.lastChunkHash ?? state.currentHash;

      String newSync = state.lastSync;
      if (freshCount > state.totalRecordsSent) {
        final now = DateTime.now();
        newSync =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        await _storage.write('last_sync', newSync);
      } else {
        newSync = await _storage.read('last_sync') ?? state.lastSync;
      }

      if (freshCount != state.totalRecordsSent ||
          nowCollecting != state.isCollecting ||
          newSync != state.lastSync ||
          freshPending.length != state.pendingChunks ||
          freshHash != state.currentHash) {
        state = state.copyWith(
          totalRecordsSent: freshCount,
          lastSync: newSync,
          isCollecting: nowCollecting,
          pendingChunks: freshPending.length,
          currentHash: freshHash,
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

  /// Pause data collection by pausing the loop inside the Foreground Service
  Future<void> pauseCollection() async {
    await _storage.write('active_$bandoId', 'false');
    await _storage.write('any_bando_active', 'false');
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("syncBandiState");
    }
    state = state.copyWith(isCollecting: false);
  }

  /// Resume data collection by starting the Foreground Service or invoking it
  Future<void> resumeCollection() async {
    // Only resume if permissions are still valid
    if (state.permissions.values.every((v) => v == true)) {
      await _storage.write('active_$bandoId', 'true');
      await _storage.write('any_bando_active', 'true');
      await _storage.write('current_bando_id', bandoId);
      final service = FlutterBackgroundService();
      if (!(await service.isRunning())) {
        await service.startService();
      } else {
        service.invoke("syncBandiState");
      }
      state = state.copyWith(isCollecting: true);
    }
  }

  /// Get current data summary from database
  Future<Map<String, int>> getSensorCounts() async {
    return await _db.sensorDao.getCountsPerType(bandoId);
  }

  /// Get the last [limit] records for a specific [sensorType]
  Future<List<SensorData>> getLastRecords(
    String sensorType, {
    int limit = 10,
  }) async {
    return await _db.sensorDao.getLastRecords(sensorType, bandoId, limit);
  }

  /// Force-uploads all pending chunks to the backend.
  /// For the MVP this simulates the upload and reports the final hash.
  Future<void> forceUpload() async {
    state = state.copyWith(isUploading: true);

    try {
      final pending = await _db.chunkDao.getPendingChunks();

      if (pending.isEmpty) {
        state = state.copyWith(isUploading: false);
        return;
      }

      // In production: upload each chunk via DataUploadRemote.uploadChunk()
      // For MVP: simulate network delay per chunk
      for (var i = 0; i < pending.length; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        // final chunk = pending[i];
        // await _uploadRemote.uploadChunk(
        //   sessionId: chunk.sessionId,
        //   chunkHash: chunk.chunkHash,
        //   dataPayload: chunk.dataPayload,
        // );
      }

      // Mark all chunks as uploaded
      await _db.chunkDao.markAsUploaded(pending.map((c) => c.id).toList());

      // The final hash is the rolling hash of the last chunk
      final finalHash = pending.last.chunkHash;

      final now = DateTime.now();
      final label =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} '
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
      await _storage.write('last_sync', label);

      final freshCount = await _db.sensorDao.totalCount(bandoId);
      final freshPending = await _db.chunkDao.getPendingChunks();

      state = state.copyWith(
        isUploading: false,
        totalRecordsSent: freshCount,
        lastSync: label,
        pendingChunks: freshPending.length,
        currentHash: finalHash,
      );
    } catch (e) {
      state = state.copyWith(isUploading: false);
      rethrow;
    }
  }

  /// Generates 100 random sensor samples, inserts them to DB, then "uploads" them.
  Future<void> uploadRandomRecords() async {
    state = state.copyWith(isUploading: true);

    final random = Random();
    final sessionId = 'manual-${DateTime.now().millisecondsSinceEpoch}';

    final batch = List.generate(100, (i) {
      final type = ['accelerometer', 'gyroscope', 'magnetometer'][i % 3];
      return SensorDataTableCompanion.insert(
        bandoId: Value(bandoId),
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

    await _db.sensorDao.insertBatch(batch);
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final label =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} '
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
    await _storage.write('last_sync', label);

    final freshCount = await _db.sensorDao.totalCount(bandoId);
    state = state.copyWith(
      isUploading: false,
      totalRecordsSent: freshCount,
      lastSync: label,
    );
  }
}

final homeProvider =
    StateNotifierProvider.family<HomeController, HomeState, String>((
      ref,
      bandoId,
    ) {
      return HomeController(bandoId);
    });
