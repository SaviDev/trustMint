// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $SessionRecordTableTable get sessionRecordTable =>
      attachedDatabase.sessionRecordTable;
  SessionDaoManager get managers => SessionDaoManager(this);
}

class SessionDaoManager {
  final _$SessionDaoMixin _db;
  SessionDaoManager(this._db);
  $$SessionRecordTableTableTableManager get sessionRecordTable =>
      $$SessionRecordTableTableTableManager(
        _db.attachedDatabase,
        _db.sessionRecordTable,
      );
}
