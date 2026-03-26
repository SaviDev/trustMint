import 'dart:async';
import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../data/local/database/app_database.dart';
import '../data/local/secure_storage.dart';
import '../data/chain/iota_chain_service.dart';

const Duration _kSampleInterval = Duration(milliseconds: 200); // 5 Hz
const Duration _kChunkInterval = Duration(seconds: 10);

/// Collects accelerometer, gyroscope and magnetometer data in a continuous loop.
/// Batches them every 10 seconds, calculates a rolling SHA-256 hash, and saves a Chunk Record.
class SensorLoop {
  final AppDatabase _db;
  final String _userId;
  final String _sessionId;
  final String bandoId;
  final IotaChainService _chainService;

  final List<SensorDataTableCompanion> _buffer = [];
  final List<SensorDataTableCompanion> _dbWriteBuffer =
      []; // For fast UI updates
  bool _isProcessingChunk = false;
  String _currentHash = '';

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  Timer? _batteryTimer;
  Timer? _chunkTimer;
  Timer? _dbWriteTimer;

  SensorLoop({
    required AppDatabase db,
    required String userId,
    required String sessionId,
    required this.bandoId,
    IotaChainService? chainService,
  }) : _db = db,
       _userId = userId,
       _sessionId = sessionId,
       _chainService = chainService ?? IotaChainService();

  Future<void> start() async {
    // Initialize hash chain state
    var session = await _db.sessionDao.getActiveSession();
    if (session == null) {
      await _db.sessionDao.saveSession(
        SessionRecordTableCompanion.insert(
          id: _sessionId,
          bandoId: bandoId,
          status: 'running',
          startTime: DateTime.now(),
          lastChunkHash: Value(_sessionId), // Genesis hash setup
        ),
      );
      session = await _db.sessionDao.getActiveSession();
    }
    _currentHash = session?.lastChunkHash ?? _sessionId; // Genesis hash

    _batteryTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _logBattery(),
    );
    _chunkTimer = Timer.periodic(_kChunkInterval, (_) => _processChunk());
    // Write to DB every 1 second instead of every sample to avoid SQLite locking
    _dbWriteTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _flushDbBuffer(),
    );

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
    final entry = SensorDataTableCompanion.insert(
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
    );

    _buffer.add(entry);

    _dbWriteBuffer.add(entry);
  }

  Future<void> _flushDbBuffer() async {
    if (_dbWriteBuffer.isEmpty) return;

    try {
      final batch = List<SensorDataTableCompanion>.from(_dbWriteBuffer);
      _dbWriteBuffer.clear();
      await _db.sensorDao.insertBatch(batch);
    } catch (e) {
      print('DB Flush error: $e');
    }
  }

  Future<void> _processChunk() async {
    if (_buffer.isEmpty || _isProcessingChunk) return;
    _isProcessingChunk = true;

    try {
      final batch = List<SensorDataTableCompanion>.from(_buffer);
      _buffer.clear();

      // Serialize batch values for hashing
      final batchJson = jsonEncode(
        batch.map((e) => jsonDecode(e.value.value)).toList(),
      );

      // Calculate H_n = SHA-256(H_{n-1} + Chunk_n)
      final inputBytes = utf8.encode(_currentHash + batchJson);
      final newHash = sha256.convert(inputBytes).toString();
      _currentHash = newHash;

      // Save to ChunkRecordTable
      final chunk = ChunkRecordTableCompanion.insert(
        sessionId: _sessionId,
        dataPayload: batchJson,
        chunkHash: newHash,
        createdAt: DateTime.now(),
      );

      await _db.chunkDao.insertChunk(chunk);
      await _db.sessionDao.updateLastChunkHash(_sessionId, newHash);

      // The raw rows are already saved immediately in _onSample for UI responsiveness,
      // so we do not need to call insertBatch(batch) here anymore.

      // Commit the new rolling hash on-chain (best-effort).
      await _chainService.updateDataHash(bandoId: bandoId, newHashHex: newHash);
    } catch (e) {
      print('SensorLoop Chunk processing error: $e');
    } finally {
      _isProcessingChunk = false;
    }
  }

  Future<void> _logBattery() async {
    final battery = Battery();
    final level = await battery.batteryLevel;
    _onSample('battery', level.toDouble(), 0, 0);
  }

  Future<void> stop() async {
    _batteryTimer?.cancel();
    _chunkTimer?.cancel();
    _dbWriteTimer?.cancel();
    await _accelSub?.cancel();
    await _gyroSub?.cancel();
    await _magSub?.cancel();
    await _processChunk(); // Final flush
    await _flushDbBuffer();
  }
}

/// Factory that reads userId from SecureStorage and returns a ready SensorLoop.
Future<SensorLoop> createSensorLoop(String sessionId, String bandoId) async {
  final storage = SecureStorage();
  final userId = await storage.getUserId() ?? 'unknown';
  final db = dbInstance;
  return SensorLoop(
    db: db,
    userId: userId,
    sessionId: sessionId,
    bandoId: bandoId,
  );
}
