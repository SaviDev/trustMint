import 'sensor_spec.dart';
import 'ema_config.dart';

class Bando {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final double payout;
  final List<SensorSpec> requiredSensors;
  final EmaConfig? emaConfig;

  Bando({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.payout,
    required this.requiredSensors,
    this.emaConfig,
  });
}
