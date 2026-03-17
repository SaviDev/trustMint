import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // TODO: Instanziare AppDatabase e DataUploadRemote
    // Leggere db e upload
    return Future.value(true);
  });
}
