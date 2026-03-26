import 'package:drift/drift.dart';
import 'app_database.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [SessionRecordTable])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(AppDatabase db) : super(db);

  Future<void> saveSession(SessionRecordTableCompanion entry) =>
      into(sessionRecordTable).insertOnConflictUpdate(entry);

  Future<SessionRecord?> getActiveSession() => (select(
    sessionRecordTable,
  )..where((t) => t.status.equals('running'))).getSingleOrNull();

  Future<void> updateLastChunkHash(String sessionId, String hash) =>
      (update(sessionRecordTable)..where((t) => t.id.equals(sessionId)))
          .write(SessionRecordTableCompanion(lastChunkHash: Value(hash)));
}
