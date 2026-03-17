import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerSource {
  Stream<AccelerometerEvent> get stream => accelerometerEventStream();
}
