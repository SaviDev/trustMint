import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'sensor_dao.dart';
import 'ema_dao.dart';
import 'session_dao.dart';

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

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────
// Database
// ─────────────────────────────────────────────────

@DriftDatabase(
  tables: [SensorDataTable, EmaResponseTable, SessionRecordTable],
  daos: [SensorDao, EmaDao, SessionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
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
    return NativeDatabase.createInBackground(file);
  });
}
