class PredictionResult {
  const PredictionResult({
    required this.label,
    this.confidence,
    this.modelUsed,
  });

  final String label;
  final double? confidence;
  final String? modelUsed;

  String get displayLabel => switch (label.toLowerCase()) {
    'safe_riding' => 'Safe Riding',
    'moderate_risk' => 'Moderate Risk',
    'high_risk' => 'High Risk',
    'possible_accident' => 'Possible Accident',
    _ => label.replaceAll('_', ' '),
  };
}

class BackendResult {
  const BackendResult({
    required this.status,
    required this.rideId,
    required this.helmetBufferSize,
    required this.chestBufferSize,
    required this.pairedBufferSize,
    required this.requiredReadings,
    this.finalState,
    this.accidentStreak,
    this.impactGatePassed,
    this.isHelmetStationary,
    this.isChestStationary,
    this.bothStationary,
    this.fusedPrediction,
    this.fusedConfidence,
    this.prediction,
  });

  final String status;
  final String rideId;
  final int helmetBufferSize;
  final int chestBufferSize;
  final int pairedBufferSize;
  final int requiredReadings;
  final String? finalState;
  final int? accidentStreak;
  final bool? impactGatePassed;
  final bool? isHelmetStationary;
  final bool? isChestStationary;
  final bool? bothStationary;
  final String? fusedPrediction;
  final double? fusedConfidence;
  final PredictionResult? prediction;

  bool get isCollecting => status.toLowerCase() == 'collecting';
}
