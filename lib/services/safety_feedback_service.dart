import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/safety_control.dart';
import '../models/safety_status.dart';
import 'ble_service.dart';

abstract interface class SafetyFeedbackController {
  Future<void> sendSafetyFeedback(RiderSafetyState state);
}

enum SafetyCommandStatus { waiting, sent, failed }

class SafetyFeedbackSnapshot {
  const SafetyFeedbackSnapshot({
    this.lastCommand,
    this.status = SafetyCommandStatus.waiting,
  });

  final SafetyControlCommand? lastCommand;
  final SafetyCommandStatus status;
}

class BleSafetyFeedbackController implements SafetyFeedbackController {
  BleSafetyFeedbackController(this._ble) {
    _bleStateSubscription = _ble.stateStream.listen(_handleBleState);
  }

  final NeoRiderBleService _ble;
  final _snapshotController =
      StreamController<SafetyFeedbackSnapshot>.broadcast();
  late final StreamSubscription<NeoRiderBleState> _bleStateSubscription;
  RiderSafetyState _currentState = RiderSafetyState.unknown;
  SafetyControlCommand? _lastSentCommand;
  bool _replayedForConnection = false;
  bool _disposed = false;

  SafetyFeedbackSnapshot snapshot = const SafetyFeedbackSnapshot();
  Stream<SafetyFeedbackSnapshot> get snapshotStream =>
      _snapshotController.stream;
  bool get canSend => _ble.canSendSafetyFeedback;

  @override
  Future<void> sendSafetyFeedback(RiderSafetyState state) async {
    if (_disposed || state == RiderSafetyState.unknown) return;
    _currentState = state;
    debugPrint(
      '[FRONTEND][FEEDBACK] vibration=${state == RiderSafetyState.accident} '
      'buzzer=${state == RiderSafetyState.accident}',
    );
    await _send(_commandFor(state));
  }

  Future<void> _send(
    SafetyControlCommand command, {
    bool replay = false,
  }) async {
    if (!replay && command == _lastSentCommand) return;
    debugPrint(
      '[FEEDBACK] state=${_currentState.name.toUpperCase()} '
      'command=${command.hex}',
    );
    final sent = await _ble.sendSafetyCommand(command);
    if (_disposed) return;
    if (sent) _lastSentCommand = command;
    _publish(
      SafetyFeedbackSnapshot(
        lastCommand: command,
        status: sent ? SafetyCommandStatus.sent : SafetyCommandStatus.failed,
      ),
    );
  }

  void _handleBleState(NeoRiderBleState state) {
    if (state != NeoRiderBleState.connected) {
      _lastSentCommand = null;
      _replayedForConnection = false;
      return;
    }
    if (_replayedForConnection) return;
    _replayedForConnection = true;
    if (_currentState != RiderSafetyState.unknown &&
        _ble.canSendSafetyFeedback) {
      unawaited(_send(_commandFor(_currentState), replay: true));
    }
  }

  SafetyControlCommand _commandFor(RiderSafetyState state) => switch (state) {
    RiderSafetyState.safe => safetyCommandForFinalState('SAFE'),
    RiderSafetyState.risk => safetyCommandForFinalState('RISK'),
    RiderSafetyState.accident =>
      safetyCommandForFinalState('ACCIDENT_CONFIRMED'),
    RiderSafetyState.unknown => safetyCommandForFinalState('UNKNOWN'),
  };

  void _publish(SafetyFeedbackSnapshot value) {
    snapshot = value;
    if (!_snapshotController.isClosed) _snapshotController.add(value);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _bleStateSubscription.cancel();
    await _snapshotController.close();
  }
}

/// Placeholder until ESP32 firmware exposes a documented writable control
/// characteristic. Sensor notification characteristics are never written to.
class UnavailableSafetyFeedbackController implements SafetyFeedbackController {
  @override
  Future<void> sendSafetyFeedback(RiderSafetyState state) async {
    debugPrint(
      '[FRONTEND][FEEDBACK] vibration=${state == RiderSafetyState.accident} '
      'buzzer=${state == RiderSafetyState.accident} '
      'requested=${state.name.toUpperCase()} '
      '(not sent: no writable control characteristic is defined)',
    );
  }
}
