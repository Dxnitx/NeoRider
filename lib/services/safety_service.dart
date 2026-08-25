import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/prediction_result.dart';
import '../models/safety_event.dart';
import '../models/safety_status.dart';
import 'safety_feedback_service.dart';

class SafetyTransition {
  const SafetyTransition({required this.previous, required this.current});
  final RiderSafetyState previous;
  final SafetyStatus current;
}

class NeoRiderSafetyService {
  NeoRiderSafetyService({SafetyFeedbackController? feedback})
    : _feedback = feedback ?? UnavailableSafetyFeedbackController();

  final SafetyFeedbackController _feedback;
  final _statusController = StreamController<SafetyStatus>.broadcast();
  final _transitionController = StreamController<SafetyTransition>.broadcast();
  final List<SafetyEvent> _events = [];
  bool _disposed = false;

  SafetyStatus current = SafetyStatus.waiting();
  Stream<SafetyStatus> get statusStream => _statusController.stream;
  Stream<SafetyTransition> get transitionStream => _transitionController.stream;
  List<SafetyEvent> get events => List.unmodifiable(_events);

  void receiveFinalState(
    String finalState, {
    PredictionResult? prediction,
    required String rideId,
    required int sequence,
  }) {
    if (_disposed) return;
    final normalized = finalState.trim().toUpperCase();
    final mapped = mapFinalState(normalized);
    debugPrint(
      '[FRONTEND][SAFETY] final_state=$normalized '
      'confidence=${prediction?.confidence}',
    );
    if (normalized == 'UNKNOWN') {
      _transition(_status(normalized, prediction, mapped), rideId, sequence);
      return;
    }
    if (mapped == RiderSafetyState.unknown) {
      debugPrint('[FRONTEND][SAFETY] unsupported final_state=$normalized');
      return;
    }
    final next = _status(normalized, prediction, mapped);
    if (current.state == mapped) {
      _publish(current: next);
    } else {
      _transition(next, rideId, sequence);
    }
  }

  RiderSafetyState mapFinalState(String state) => switch (state.toUpperCase()) {
    'SAFE' => RiderSafetyState.safe,
    'RISK' || 'ACCIDENT_PENDING' => RiderSafetyState.risk,
    'ACCIDENT_CONFIRMED' => RiderSafetyState.accident,
    _ => RiderSafetyState.unknown,
  };

  SafetyStatus _status(
    String finalState,
    PredictionResult? prediction,
    RiderSafetyState state,
  ) => SafetyStatus(
    state: state,
    rawPrediction: finalState,
    confidence: prediction?.confidence,
    modelUsed: prediction?.modelUsed,
    receivedAt: DateTime.now(),
  );

  void _transition(SafetyStatus next, String rideId, int sequence) {
    if (next.state == current.state) return;
    final previous = current.state;
    current = next;
    _events.add(
      SafetyEvent(
        rideId: rideId,
        timestamp: next.receivedAt,
        safetyState: next.state,
        rawPrediction: next.rawPrediction,
        confidence: next.confidence,
        helmetSequence: sequence,
        chestSequence: sequence,
      ),
    );
    debugPrint(
      '[SAFETY] state ${previous.name.toUpperCase()} -> '
      '${next.state.name.toUpperCase()}',
    );
    _publish(current: next);
    if (!_transitionController.isClosed) {
      _transitionController.add(
        SafetyTransition(previous: previous, current: next),
      );
    }
    unawaited(_feedback.sendSafetyFeedback(next.state));
  }

  void _publish({required SafetyStatus current}) {
    this.current = current;
    if (!_statusController.isClosed) _statusController.add(current);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _statusController.close();
    await _transitionController.close();
  }
}
