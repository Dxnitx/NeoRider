import 'safety_status.dart';

class SafetyEvent {
  const SafetyEvent({
    required this.rideId,
    required this.timestamp,
    required this.safetyState,
    required this.rawPrediction,
    required this.helmetSequence,
    required this.chestSequence,
    this.confidence,
  });

  final String rideId;
  final DateTime timestamp;
  final RiderSafetyState safetyState;
  final String rawPrediction;
  final double? confidence;
  final int helmetSequence;
  final int chestSequence;
}
