import 'dart:ui';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/local/secure_storage.dart';
import 'sensor_loop.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Timer? _surveyTimer;
Timer? _uploadTimer;

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
      initialNotificationContent: 'Sensor collection active...',
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
  await dotenv.load(fileName: ".env");

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

  // Read the active bandoId and userId persisted by the UI isolate from SecureStorage
  SensorLoop? loop;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_bg_service_small');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  Future<void> syncBandiState() async {
    final storage = SecureStorage();
    final anyBandoActive = await storage.read('any_bando_active') == 'true';
    final b1Active =
        await storage.read('active_dummy_1') == 'true' || anyBandoActive;
    final b2Active = await storage.read('active_b2') == 'true'; // Legacy

    // Daily Sensors Logic
    if (b1Active && loop == null) {
      final currentBandoId =
          await storage.read('current_bando_id') ?? 'dummy_1';
      print(
        '[BGS] Bando ACTIVE. Starting loop and upload timer for $currentBandoId.',
      );
      loop = await createSensorLoop(sessionId, currentBandoId);
      loop!.start();
      _uploadTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
        final n = DateTime.now();
        final l =
            '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')} ${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}';
        await SecureStorage().write('last_sync', l);
      });
    } else if (!b1Active && loop != null) {
      print('[BGS] Bando INACTIVE. Halting sensors.');
      await loop!.stop();
      loop = null;
      _uploadTimer?.cancel();
      _uploadTimer = null;
    }

    // Daily Mood Logic
    if (b2Active && _surveyTimer == null) {
      print('[BGS] Bando b2 ACTIVE. Starting survey notifications.');
      _surveyTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        flutterLocalNotificationsPlugin.show(
          id: 0,
          title: 'Daily Mood Survey 🔔',
          body: 'It is time to log your daily mood! Tap to open.',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'data_collector_channel',
              'Data Collector Service',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      });
    } else if (!b2Active && _surveyTimer != null) {
      print('[BGS] Bando b2 INACTIVE. Halting surveys.');
      _surveyTimer?.cancel();
      _surveyTimer = null;
    }

    // Self kill if both are entirely deactivated to save battery
    if (!b1Active && !b2Active) {
      print('[BGS] Zero bandos active. Killing Foreground Service.');
      service.stopSelf();
    }
  }

  // Initial Check
  await syncBandiState();

  // Unified dynamic synchronizer endpoint
  service.on('syncBandiState').listen((_) async {
    print('[BGS] Received syncBandiState event!');
    await syncBandiState();
  });

  service.on('stopService').listen((_) async {
    _surveyTimer?.cancel();
    _uploadTimer?.cancel();
    if (loop != null) await loop!.stop();
    service.stopSelf();
  });
}

String _p(int n) => n.toString().padLeft(2, '0');
