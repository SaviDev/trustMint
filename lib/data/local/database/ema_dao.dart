import 'package:drift/drift.dart';
import 'app_database.dart';

part 'ema_dao.g.dart';

@DriftAccessor(tables: [EmaResponseTable])
class EmaDao extends DatabaseAccessor<AppDatabase> with _$EmaDaoMixin {
  EmaDao(AppDatabase db) : super(db);

  Future<int> insertResponse(EmaResponseTableCompanion entry) =>
      into(emaResponseTable).insert(entry);

  Future<List<EmaResponse>> getUnsyncedResponses() =>
      (select(emaResponseTable)..where((t) => t.isSynced.equals(false))).get();
}
