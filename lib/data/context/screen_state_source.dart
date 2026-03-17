import 'package:flutter/services.dart';

class ScreenStateSource {
  // Riceve eventi da ScreenStateReceiver.kt
  static const EventChannel _channel = EventChannel('com.antigravity.data_collection_app/screen');

  Stream<bool> get isScreenOn => _channel.receiveBroadcastStream().map((event) => event == 'SCREEN_ON');
}
