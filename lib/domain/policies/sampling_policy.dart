class SamplingPolicy {
  /// Ritorna True se bisogna sospendere temporaneamente la raccolta
  bool shouldSuspendCollection(int batteryLevel) {
    return batteryLevel <= 15;
  }

  /// Adatta la frequenza di campionamento (es. dimezza se batteria < 30%)
  int adaptSamplingRate(int targetHz, int batteryLevel) {
    if (batteryLevel < 30) {
      return targetHz ~/ 2;
    }
    return targetHz;
  }
}
