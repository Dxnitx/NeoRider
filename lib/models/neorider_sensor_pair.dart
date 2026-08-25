import 'ble_sensor_reading.dart';

class NeoRiderSensorPair {
  NeoRiderSensorPair({
    required this.sequence,
    required this.helmet,
    required this.chest,
    required this.receivedAt,
  }) : assert(helmet.sequence == sequence && chest.sequence == sequence);

  final int sequence;
  final BleSensorReading helmet;
  final BleSensorReading chest;
  final DateTime receivedAt;

  @override
  String toString() =>
      'NeoRiderSensorPair(sequence: $sequence, '
      'receivedAt: $receivedAt, helmet: $helmet, chest: $chest)';
}
