// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chunk_dao.dart';

// ignore_for_file: type=lint
mixin _$ChunkDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChunkRecordTableTable get chunkRecordTable =>
      attachedDatabase.chunkRecordTable;
  ChunkDaoManager get managers => ChunkDaoManager(this);
}

class ChunkDaoManager {
  final _$ChunkDaoMixin _db;
  ChunkDaoManager(this._db);
  $$ChunkRecordTableTableTableManager get chunkRecordTable =>
      $$ChunkRecordTableTableTableManager(
        _db.attachedDatabase,
        _db.chunkRecordTable,
      );
}
