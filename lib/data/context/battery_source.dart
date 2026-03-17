import 'package:battery_plus/battery_plus.dart';

class BatterySource {
  final Battery _battery = Battery();

  Future<int> get batteryLevel => _battery.batteryLevel;
  Stream<BatteryState> get batteryState => _battery.onBatteryStateChanged;
}
