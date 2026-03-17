class ConsentProfile {
  final String bandoId;
  final List<String> grantedSensors;
  final bool emaConsent;
  final DateTime timestamp;

  ConsentProfile({
    required this.bandoId,
    required this.grantedSensors,
    required this.emaConsent,
    required this.timestamp,
  });
}
