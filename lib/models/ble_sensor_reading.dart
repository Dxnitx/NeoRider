class BleSensorReading {
  const BleSensorReading({
    required this.sequence,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.pitch,
    required this.roll,
    required this.yaw,
  });

  final int sequence;
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double pitch;
  final double roll;
  final double yaw;

  @override
  String toString() =>
      'BleSensorReading(sequence: $sequence, '
      'accel: [$accelX, $accelY, $accelZ] g, '
      'gyro: [$gyroX, $gyroY, $gyroZ] deg/s, '
      'angles: [$pitch, $roll, $yaw]°)';
}
