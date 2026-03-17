// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ema_dao.dart';

// ignore_for_file: type=lint
mixin _$EmaDaoMixin on DatabaseAccessor<AppDatabase> {
  $EmaResponseTableTable get emaResponseTable =>
      attachedDatabase.emaResponseTable;
  EmaDaoManager get managers => EmaDaoManager(this);
}

class EmaDaoManager {
  final _$EmaDaoMixin _db;
  EmaDaoManager(this._db);
  $$EmaResponseTableTableTableManager get emaResponseTable =>
      $$EmaResponseTableTableTableManager(
        _db.attachedDatabase,
        _db.emaResponseTable,
      );
}
