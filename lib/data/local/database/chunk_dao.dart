import 'package:drift/drift.dart';
import 'app_database.dart';

part 'chunk_dao.g.dart';

@DriftAccessor(tables: [ChunkRecordTable])
class ChunkDao extends DatabaseAccessor<AppDatabase> with _$ChunkDaoMixin {
  ChunkDao(AppDatabase db) : super(db);

  Future<void> insertChunk(ChunkRecordTableCompanion entry) =>
      into(chunkRecordTable).insert(entry);

  Future<List<ChunkRecord>> getPendingChunks() =>
      (select(chunkRecordTable)..where((t) => t.isUploaded.equals(false))).get();

  Future<void> markAsUploaded(List<int> ids) =>
      (update(chunkRecordTable)..where((t) => t.id.isIn(ids)))
          .write(const ChunkRecordTableCompanion(isUploaded: Value(true)));

  Future<void> deleteUploadedChunks() =>
      (delete(chunkRecordTable)..where((t) => t.isUploaded.equals(true))).go();
}
