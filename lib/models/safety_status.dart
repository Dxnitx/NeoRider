enum RiderSafetyState { unknown, safe, risk, accident }

class SafetyStatus {
  const SafetyStatus({
    required this.state,
    required this.rawPrediction,
    required this.receivedAt,
    this.confidence,
    this.modelUsed,
  });

  factory SafetyStatus.waiting() => SafetyStatus(
    state: RiderSafetyState.unknown,
    rawPrediction: 'waiting',
    receivedAt: DateTime.now(),
  );

  final RiderSafetyState state;
  final String rawPrediction;
  final double? confidence;
  final String? modelUsed;
  final DateTime receivedAt;

  String get title => switch (state) {
    RiderSafetyState.safe => 'Safe Riding',
    RiderSafetyState.risk => 'Risk Detected',
    RiderSafetyState.accident => 'Possible Accident Detected',
    RiderSafetyState.unknown => 'Waiting for Prediction',
  };

  String get message => switch (state) {
    RiderSafetyState.safe =>
      'Riding behaviour is within the expected safe range.',
    RiderSafetyState.risk =>
      'Unsafe riding behaviour detected. Reduce speed and stabilize your riding posture.',
    RiderSafetyState.accident =>
      'A possible accident has been detected. Stop safely and check your condition.',
    RiderSafetyState.unknown => 'Waiting for a recognized backend prediction.',
  };
}
