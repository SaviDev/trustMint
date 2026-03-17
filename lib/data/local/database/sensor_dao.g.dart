// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_dao.dart';

// ignore_for_file: type=lint
mixin _$SensorDaoMixin on DatabaseAccessor<AppDatabase> {
  $SensorDataTableTable get sensorDataTable => attachedDatabase.sensorDataTable;
  SensorDaoManager get managers => SensorDaoManager(this);
}

class SensorDaoManager {
  final _$SensorDaoMixin _db;
  SensorDaoManager(this._db);
  $$SensorDataTableTableTableManager get sensorDataTable =>
      $$SensorDataTableTableTableManager(
        _db.attachedDatabase,
        _db.sensorDataTable,
      );
}
