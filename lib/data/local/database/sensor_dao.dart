import 'package:drift/drift.dart';
import 'app_database.dart';

part 'sensor_dao.g.dart';

@DriftAccessor(tables: [SensorDataTable])
class SensorDao extends DatabaseAccessor<AppDatabase> with _$SensorDaoMixin {
  SensorDao(super.db);

  /// Insert a single sensor sample.
  Future<int> insertSample(SensorDataTableCompanion entry) =>
      into(sensorDataTable).insert(entry);

  /// Insert multiple samples at once (batch write).
  Future<void> insertBatch(List<SensorDataTableCompanion> entries) =>
      batch((b) => b.insertAll(sensorDataTable, entries));

  /// Returns all samples not yet uploaded.
  Future<List<SensorData>> getUnsynced() =>
      (select(sensorDataTable)
            ..where((t) => t.isSynced.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();

  /// Total count of all samples stored locally.
  Future<int> totalCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM sensor_data_table',
      readsFrom: {sensorDataTable},
    ).getSingle();
    return row.read<int>('c');
  }

  /// Mark a list of ids as synced after successful upload.
  Future<void> markSynced(List<int> ids) =>
      (update(sensorDataTable)..where((t) => t.id.isIn(ids))).write(
        const SensorDataTableCompanion(isSynced: Value(true)),
      );

  /// Returns the count of records for each sensor type
  Future<Map<String, int>> getCountsPerType() async {
    final query = selectOnly(sensorDataTable)
      ..addColumns([sensorDataTable.sensorType, sensorDataTable.id.count()])
      ..groupBy([sensorDataTable.sensorType]);

    final results = await query.get();
    final map = <String, int>{};
    for (var row in results) {
      final type = row.read(sensorDataTable.sensorType);
      final count = row.read(sensorDataTable.id.count());
      if (type != null && count != null) {
        map[type] = count;
      }
    }
    return map;
  }

  /// Returns the latest [limit] records for a specific sensor type.
  Future<List<SensorData>> getLastRecords(String type, int limit) =>
      (select(sensorDataTable)
            ..where((t) => t.sensorType.equals(type))
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(limit))
          .get();
}
