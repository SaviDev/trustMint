import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'sensor_dao.dart';
import 'ema_dao.dart';
import 'session_dao.dart';
import 'chunk_dao.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────
// Tables
// ─────────────────────────────────────────────────

/// One row = one sensor sample.
/// Column `value` stores compact JSON: {"x":0.12,"y":-9.81,"z":0.03}
@DataClassName('SensorData')
class SensorDataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get bandoId => text().nullable()(); // Added in v2
  TextColumn get sessionId => text()();
  TextColumn get sensorType =>
      text()(); // "accelerometer"|"gyroscope"|"magnetometer"
  TextColumn get value => text()(); // JSON {"x":…,"y":…,"z":…}
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('EmaResponse')
class EmaResponseTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bandoId => text()();
  TextColumn get questionId => text()();
  TextColumn get answer => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('SessionRecord')
class SessionRecordTable extends Table {
  TextColumn get id => text()();
  TextColumn get bandoId => text()();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get status => text()(); // running | paused | stopped
  TextColumn get lastChunkHash => text().nullable()(); // Rolling Hash State

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ChunkRecord')
class ChunkRecordTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get dataPayload => text()(); // The JSON payload of the 10s batch
  TextColumn get chunkHash => text()(); // Hash of this chunk
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
}

// ─────────────────────────────────────────────────
// Database
// ─────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    SensorDataTable,
    EmaResponseTable,
    SessionRecordTable,
    ChunkRecordTable,
  ],
  daos: [SensorDao, EmaDao, SessionDao, ChunkDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from <= 1) {
          await m.addColumn(sensorDataTable, sensorDataTable.bandoId);
        }
        if (from <= 2) {
          await m.addColumn(
            sessionRecordTable,
            sessionRecordTable.lastChunkHash,
          );
          await m.createTable(chunkRecordTable);
        }
      },
    );
  }
}

// Global lazy instance — opened once per isolate.
// The UI isolate and background isolate each hold their own connection to
// the same physical SQLite file on disk.
AppDatabase? _dbInstance;
AppDatabase get dbInstance {
  _dbInstance ??= AppDatabase();
  return _dbInstance!;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'data_collector.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Enable Write-Ahead Logging to allow concurrent read/writes from different isolates
        db.execute('PRAGMA journal_mode=WAL;');
      },
    );
  });
}
