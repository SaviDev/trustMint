import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import '../data/local/secure_storage.dart';
import 'sensor_loop.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Called once at startup to configure the background service.
Future<void> initBackgroundService() async {
  // Create the notification channel required by Android 8+ for Foreground Services
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'data_collector_channel', // id
    'Data Collector Service', // name
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at least LOW for FGS
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart:
          false, // Do NOT auto-start to avoid Android 14 FGS crashes before permissions are granted
      isForegroundMode: true,
      notificationChannelId: 'data_collector_channel',
      initialNotificationTitle: 'Data Collector',
      initialNotificationContent: 'Raccolta sensori attiva…',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(autoStart: false, onForeground: onStart),
  );
}

/// Entry-point for the background isolate.
/// This function runs in a completely separate isolate from the UI.
/// The only shared state is the SQLite database file on disk.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service
        .on('setAsForeground')
        .listen((_) => service.setAsForegroundService());
    service
        .on('setAsBackground')
        .listen((_) => service.setAsBackgroundService());
  }

  // Build a sessionId from the current date+time so records are grouped
  final now = DateTime.now();
  final sessionId =
      'sess-${now.year}${_p(now.month)}${_p(now.day)}-${_p(now.hour)}${_p(now.minute)}';

  // Read the userId persisted by the UI isolate from SecureStorage
  final storage = SecureStorage();
  final userId = await storage.getUserId() ?? 'unknown';

  // Create and start the real sensor loop
  final loop = await createSensorLoop(sessionId);
  loop.start();

  // Update the FGS notification content periodically so the user can see
  // the service is alive, and respond to stop requests
  service.on('stopService').listen((_) async {
    await loop.stop();
    service.stopSelf();
  });
}

String _p(int n) => n.toString().padLeft(2, '0');
