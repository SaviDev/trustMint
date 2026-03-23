import 'dart:async';
import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:drift/drift.dart';
import '../data/local/database/app_database.dart';
import '../data/local/secure_storage.dart';

const int _kFlushEvery = 50;
const Duration _kSampleInterval = Duration(milliseconds: 200); // 5 Hz

/// Collects accelerometer, gyroscope and magnetometer data in a continuous loop.
/// Batches [_kFlushEvery] rows then writes them to the Drift SQLite DB.
class SensorLoop {
  final AppDatabase _db;
  final String _userId;
  final String _sessionId;
  final String bandoId;

  final List<SensorDataTableCompanion> _buffer = [];

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  Timer? _batteryTimer;

  SensorLoop({
    required AppDatabase db,
    required String userId,
    required String sessionId,
    required this.bandoId,
  }) : _db = db,
       _userId = userId,
       _sessionId = sessionId;

  void start() {
    _batteryTimer = Timer.periodic(const Duration(minutes: 1), (_) => _logBattery());
    _logBattery(); // Log immediately on start

    _accelSub = accelerometerEventStream(
      samplingPeriod: _kSampleInterval,
    ).listen((e) => _onSample('accelerometer', e.x, e.y, e.z), onError: (_) {});
    _gyroSub = gyroscopeEventStream(
      samplingPeriod: _kSampleInterval,
    ).listen((e) => _onSample('gyroscope', e.x, e.y, e.z), onError: (_) {});
    _magSub = magnetometerEventStream(
      samplingPeriod: _kSampleInterval,
    ).listen((e) => _onSample('magnetometer', e.x, e.y, e.z), onError: (_) {});
  }

  void _onSample(String type, double x, double y, double z) {
    _buffer.add(
      SensorDataTableCompanion.insert(
        bandoId: Value(bandoId),
        userId: _userId,
        sessionId: _sessionId,
        sensorType: type,
        value: jsonEncode({
          'x': double.parse(x.toStringAsFixed(4)),
          'y': double.parse(y.toStringAsFixed(4)),
          'z': double.parse(z.toStringAsFixed(4)),
        }),
        timestamp: DateTime.now(),
      ),
    );
    if (_buffer.length >= _kFlushEvery) _flush();
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<SensorDataTableCompanion>.from(_buffer);
    _buffer.clear();
    await _db.sensorDao.insertBatch(batch);
  }

  Future<void> _logBattery() async {
    final battery = Battery();
    final level = await battery.batteryLevel;
    _onSample('battery', level.toDouble(), 0, 0);
  }

  Future<void> stop() async {
    _batteryTimer?.cancel();
    await _accelSub?.cancel();
    await _gyroSub?.cancel();
    await _magSub?.cancel();
    await _flush();
  }
}

/// Factory that reads userId from SecureStorage and returns a ready SensorLoop.
Future<SensorLoop> createSensorLoop(String sessionId, String bandoId) async {
  final storage = SecureStorage();
  final userId = await storage.getUserId() ?? 'unknown';
  final db = dbInstance;
  return SensorLoop(db: db, userId: userId, sessionId: sessionId, bandoId: bandoId);
}

