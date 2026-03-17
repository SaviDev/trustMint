class SensorSpec {
  final String type; // e.g. 'accelerometer', 'location', 'activity'
  final int samplingRateHz;
  final int windowDurationMs; // per duty cycling

  SensorSpec({
    required this.type,
    required this.samplingRateHz,
    this.windowDurationMs = 0,
  });
}
