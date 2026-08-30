import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/ble_sensor_reading.dart';
import '../models/neorider_sensor_pair.dart';
import '../models/prediction_result.dart';
import '../models/safety_control.dart';
import 'api_service.dart';
import 'ble_service.dart';

class RideSession extends ChangeNotifier {
  RideSession._() {
    _subscriptions.addAll([
      ble.stateStream.listen((state) {
        _resetSafetyStabilizer();
        if (state == NeoRiderBleState.connected) {
          _controlCharacteristic = ble.controlCharacteristic;
          _controlResolutionRefreshAttempted = false;
          unawaited(applySafetyActuatorState(_finalState, force: true));
        } else {
          _controlCharacteristic = null;
          _controlResolutionRefreshAttempted = false;
          _lastActuatorCommand = null;
        }
        notifyListeners();
      }),
      ble.helmetStream.listen((value) {
        helmet = value;
        lastHelmetPacketTime = DateTime.now();
        notifyListeners();
      }),
      ble.chestStream.listen((value) {
        chest = value;
        lastChestPacketTime = DateTime.now();
        notifyListeners();
      }),
      ble.pairStream.listen((pair) {
        lastPairTime = DateTime.now();
        _pairForwarder.enqueue(pair);
        notifyListeners();
      }),
    ]);
    _freshnessTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  static final RideSession instance = RideSession._();
  final NeoRiderBleService ble = NeoRiderBleService();
  NeoRiderApiService? _api;
  NeoRiderPairForwarder? _forwarder;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  late final Timer _freshnessTimer;

  BleSensorReading? helmet;
  BleSensorReading? chest;
  DateTime? lastHelmetPacketTime;
  DateTime? lastChestPacketTime;
  DateTime? lastPairTime;
  BackendResult? backend;
  bool backendOnline = false;
  String? backendMessage;
  bool emergencyTriggered = false;
  DateTime? rideStartedAt;
  String _finalState = 'UNKNOWN';
  bool _hasEffectiveState = false;
  BluetoothCharacteristic? _controlCharacteristic;
  bool _controlResolutionRefreshAttempted = false;
  SafetyControlCommand? _lastActuatorCommand;
  Future<void> _actuatorWrite = Future<void>.value();
  int _lastAcceptedRequestId = -1;
  int _riskCandidateStreak = 0;
  int _safeReleaseStreak = 0;

  static const int _riskEntryRequired = 5;
  static const int _safeReleaseRequired = 3;

  bool _fresh(DateTime? value) =>
      value != null &&
      DateTime.now().difference(value) < const Duration(seconds: 2);
  bool get bleConnected => ble.state == NeoRiderBleState.connected;
  bool get helmetSensorReceiving => _fresh(lastHelmetPacketTime);
  bool get chestSensorReceiving => _fresh(lastChestPacketTime);
  bool get packetStreamStable => _fresh(lastPairTime);
  bool get readyToRide =>
      bleConnected &&
      helmetSensorReceiving &&
      chestSensorReceiving &&
      backendOnline;
  String get finalState => _finalState;
  String get prediction =>
      backend?.fusedPrediction ?? backend?.prediction?.label ?? 'UNKNOWN';
  double get confidence =>
      backend?.fusedConfidence ?? backend?.prediction?.confidence ?? 0;

  NeoRiderApiService get api => _api ??= NeoRiderApiService();

  NeoRiderPairForwarder get _pairForwarder =>
      _forwarder ??= NeoRiderPairForwarder(
        api: api,
        onSent: _onBackendResult,
        onFailure: _onBackendFailure,
      );

  Future<void> checkBackend() async {
    try {
      backendOnline = await api.checkHealth();
      backendMessage = null;
    } catch (error) {
      backendOnline = false;
      backendMessage = error.toString();
      _resetSafetyStabilizer();
      debugPrint('[API][ERROR] health status=unavailable error=$error');
      unawaited(applySafetyActuatorState('UNKNOWN', clearReason: 'API_ERROR'));
    }
    notifyListeners();
  }

  void _onBackendResult(NeoRiderSensorPair pair, BackendResult result) {
    backend = result;
    backendOnline = true;
    backendMessage = null;
    debugPrint(
      '[SAFETY][INPUT] request=${result.requestId ?? pair.sequence} '
      'device=${result.device ?? 'combined'} status=${result.status} '
      'final_state=${result.finalState} '
      'fused_prediction=${result.fusedPrediction}',
    );
    debugPrint(
      '[SAFETY][RAW] final_state=${result.finalState} '
      'fused_prediction=${result.fusedPrediction} status=${result.status}',
    );
    final requestId = result.requestId ?? pair.sequence;
    final effectiveBefore = _finalState;
    if (result.isCollecting && result.finalState == null) {
      debugPrint(
        '[SAFETY][DECISION] request=$requestId accepted=false '
        'reason=collecting effective_before=$effectiveBefore '
        'effective_after=$effectiveBefore',
      );
      notifyListeners();
      return;
    }
    if (requestId <= _lastAcceptedRequestId) {
      debugPrint(
        '[SAFETY][DECISION] request=$requestId accepted=false '
        'reason=stale_response effective_before=$effectiveBefore '
        'effective_after=$effectiveBefore',
      );
      notifyListeners();
      return;
    }
    _lastAcceptedRequestId = requestId;
    final authoritativeState = _normalizeFinalState(result.finalState);
    final stabilizedState = _stabilizeAuthoritativeState(authoritativeState);
    if (stabilizedState == null) {
      final reason = authoritativeState == 'RISK'
          ? 'risk_stabilizing'
          : 'safe_release_stabilizing';
      debugPrint(
        '[SAFETY][DECISION] request=$requestId accepted=false '
        'reason=$reason effective_before=$effectiveBefore '
        'effective_after=$effectiveBefore',
      );
      notifyListeners();
      return;
    }
    debugPrint(
      '[SAFETY][DECISION] request=$requestId accepted=true '
      'reason=authoritative_final_state effective_before=$effectiveBefore '
      'effective_after=$stabilizedState',
    );
    unawaited(applySafetyActuatorState(stabilizedState));
    notifyListeners();
  }

  void _onBackendFailure(NeoRiderSensorPair pair, Object error) {
    backendOnline = false;
    backendMessage = error.toString();
    _resetSafetyStabilizer();
    debugPrint(
      '[API][ERROR] /sensor/live status=failed sequence=${pair.sequence} '
      'error=$error',
    );
    debugPrint(
      '[SAFETY][DECISION] request=${pair.sequence} accepted=true '
      'reason=api_error effective_before=$_finalState effective_after=UNKNOWN',
    );
    unawaited(applySafetyActuatorState('UNKNOWN', clearReason: 'API_ERROR'));
    notifyListeners();
  }

  /// Applies the firmware's existing one-byte actuator protocol exactly once
  /// for each effective backend safety-state transition.
  Future<void> applySafetyActuatorState(
    String? state, {
    bool force = false,
    String? clearReason,
  }) {
    final normalized = _normalizeFinalState(state);
    debugPrint('[SAFETY][NORMALIZED] raw=$state normalized=$normalized');
    if (!force && _hasEffectiveState && normalized == _finalState) {
      return _actuatorWrite;
    }

    final previousState = _finalState;
    if (_hasEffectiveState && previousState != normalized) {
      debugPrint('[SAFETY][TRANSITION] $previousState -> $normalized');
    }
    _finalState = normalized;
    _hasEffectiveState = true;
    if (normalized == 'ACCIDENT_CONFIRMED') emergencyTriggered = true;
    if (normalized == 'SAFE') emergencyTriggered = false;
    final command = safetyCommandForFinalState(normalized);
    debugPrint('[SAFETY] final_state=$normalized');
    notifyListeners();

    if (!force && command == _lastActuatorCommand) return _actuatorWrite;
    _actuatorWrite = _actuatorWrite.then((_) async {
      if (!force && command == _lastActuatorCommand) return;
      debugPrint('[ACTUATOR][MAP] state=$normalized command=${command.hex}');
      if (command == SafetyControlCommand.clear) {
        final reason =
            clearReason ??
            (normalized == 'SAFE' ? 'SAFE_STATE' : 'UNKNOWN_API_RESPONSE');
        debugPrint('[ACTUATOR][CLEAR] reason=$reason');
      }
      final characteristic = await _resolveControlCharacteristic();
      if (characteristic == null) {
        debugPrint('[ACTUATOR][ERROR] control characteristic is null');
        return;
      }
      final supportsWithoutResponse =
          characteristic.properties.writeWithoutResponse;
      if (!supportsWithoutResponse && !characteristic.properties.write) {
        debugPrint('[ACTUATOR][WRITE][ERROR] characteristic is not writable');
        return;
      }
      debugPrint('[ACTUATOR][WRITE] state=$normalized command=${command.hex}');
      try {
        debugPrint(
          '[BLE][CONTROL][WRITE] uuid=${characteristic.uuid} '
          'command=${command.hex}',
        );
        await characteristic.write([
          command.byteValue,
        ], withoutResponse: supportsWithoutResponse);
        _lastActuatorCommand = command;
        debugPrint('[BLE][CONTROL][WRITE] success command=${command.hex}');
        debugPrint('[ACTUATOR][WRITE] SUCCESS command=${command.hex}');
      } catch (error, stackTrace) {
        debugPrint(
          '[BLE][CONTROL][WRITE] failed command=${command.hex} error=$error',
        );
        debugPrint('[ACTUATOR][WRITE][ERROR] $error');
        debugPrint('$stackTrace');
      }
    });
    return _actuatorWrite;
  }

  /// Temporary raw-byte diagnostic using the existing RideSession connection.
  Future<void> testMotor() async {
    const rawCommand = 0x01;
    debugPrint('[ACTUATOR][TEST] attempting 0x01');
    final characteristic = await _resolveControlCharacteristic();
    debugPrint(
      '[ACTUATOR][TEST] characteristic='
      '${characteristic?.uuid.toString() ?? 'null'}',
    );
    debugPrint('[ACTUATOR][TEST] connected=$bleConnected');
    debugPrint(
      '[ACTUATOR][TEST] write=${characteristic?.properties.write ?? false}',
    );
    debugPrint(
      '[ACTUATOR][TEST] writeWithoutResponse='
      '${characteristic?.properties.writeWithoutResponse ?? false}',
    );

    if (characteristic == null) {
      debugPrint('[ACTUATOR][TEST][ERROR] control characteristic is null');
      return;
    }
    if (!bleConnected) {
      debugPrint('[ACTUATOR][TEST][ERROR] BLE is not connected');
      return;
    }

    final supportsWithoutResponse =
        characteristic.properties.writeWithoutResponse;
    if (!supportsWithoutResponse && !characteristic.properties.write) {
      debugPrint('[ACTUATOR][TEST][ERROR] characteristic is not writable');
      return;
    }

    try {
      await characteristic.write(const [
        rawCommand,
      ], withoutResponse: supportsWithoutResponse);
      debugPrint('[ACTUATOR][TEST] SUCCESS 0x01');
    } catch (error, stackTrace) {
      debugPrint('[ACTUATOR][TEST][ERROR] $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> clearMotor() =>
      _writeDiagnosticCommand(SafetyControlCommand.clear, label: 'CLEAR MOTOR');

  Future<void> _writeDiagnosticCommand(
    SafetyControlCommand command, {
    required String label,
  }) async {
    final characteristic = await _resolveControlCharacteristic();
    if (characteristic == null) {
      debugPrint('[ACTUATOR][ERROR] control characteristic is null');
      return;
    }
    final supportsWithoutResponse =
        characteristic.properties.writeWithoutResponse;
    if (!supportsWithoutResponse && !characteristic.properties.write) {
      debugPrint('[ACTUATOR][WRITE][ERROR] characteristic is not writable');
      return;
    }
    debugPrint('[ACTUATOR][DIAGNOSTIC] $label command=${command.hex}');
    try {
      await characteristic.write([
        command.byteValue,
      ], withoutResponse: supportsWithoutResponse);
      debugPrint('[ACTUATOR][WRITE] SUCCESS command=${command.hex}');
    } catch (error, stackTrace) {
      debugPrint('[ACTUATOR][WRITE][ERROR] $error');
      debugPrint('$stackTrace');
    }
  }

  Future<BluetoothCharacteristic?> _resolveControlCharacteristic() async {
    debugPrint(
      '[ACTUATOR][RESOLVE] session cache='
      '${_controlCharacteristic?.uuid.toString() ?? 'null'}',
    );
    if (_controlCharacteristic != null) return _controlCharacteristic;

    final serviceCharacteristic = ble.controlCharacteristic;
    debugPrint(
      '[ACTUATOR][RESOLVE] service characteristic='
      '${serviceCharacteristic?.uuid.toString() ?? 'null'}',
    );
    if (serviceCharacteristic != null) {
      _controlCharacteristic = serviceCharacteristic;
      return serviceCharacteristic;
    }

    if (!bleConnected || _controlResolutionRefreshAttempted) return null;
    _controlResolutionRefreshAttempted = true;
    debugPrint('[ACTUATOR][RESOLVE] rediscovering GATT');
    final rediscovered = await ble.refreshControlCharacteristic();
    _controlCharacteristic = rediscovered ?? ble.controlCharacteristic;
    debugPrint(
      '[ACTUATOR][RESOLVE] after rediscovery='
      '${_controlCharacteristic?.uuid.toString() ?? 'null'}',
    );
    return _controlCharacteristic;
  }

  String _normalizeFinalState(String? state) {
    final normalized = state?.trim().toUpperCase() ?? 'UNKNOWN';
    return switch (normalized) {
      'SAFE' ||
      'RISK' ||
      'ACCIDENT_PENDING' ||
      'ACCIDENT_CONFIRMED' ||
      'UNKNOWN' => normalized,
      _ => 'UNKNOWN',
    };
  }

  String? _stabilizeAuthoritativeState(String state) {
    if (state == 'ACCIDENT_PENDING' || state == 'ACCIDENT_CONFIRMED') {
      _resetSafetyStabilizer();
      return state;
    }

    if (state == 'RISK') {
      _safeReleaseStreak = 0;
      if (_finalState == 'RISK') {
        _riskCandidateStreak = 0;
        return state;
      }
      _riskCandidateStreak++;
      final accepted = _riskCandidateStreak >= _riskEntryRequired;
      debugPrint(
        '[SAFETY][STABILIZER] risk_candidate=$_riskCandidateStreak/'
        '$_riskEntryRequired${accepted ? ' accepted=true' : ''}',
      );
      if (!accepted) return null;
      _riskCandidateStreak = 0;
      return state;
    }

    if (state == 'SAFE') {
      _riskCandidateStreak = 0;
      if (_finalState == 'RISK') {
        _safeReleaseStreak++;
        final accepted = _safeReleaseStreak >= _safeReleaseRequired;
        debugPrint(
          '[SAFETY][STABILIZER] safe_release=$_safeReleaseStreak/'
          '$_safeReleaseRequired${accepted ? ' accepted=true' : ''}',
        );
        if (!accepted) return null;
      }
      _safeReleaseStreak = 0;
      return state;
    }

    _resetSafetyStabilizer();
    return state;
  }

  void _resetSafetyStabilizer() {
    _riskCandidateStreak = 0;
    _safeReleaseStreak = 0;
  }

  void startRide() {
    if (rideStartedAt == null) {
      rideStartedAt = DateTime.now();
      _resetSafetyStabilizer();
      _lastAcceptedRequestId = -1;
    }
    notifyListeners();
  }

  void stopRide() {
    rideStartedAt = null;
    _resetSafetyStabilizer();
    _lastAcceptedRequestId = -1;
    notifyListeners();
  }

  Future<void> markSafe() async {
    emergencyTriggered = false;
    backend = null;
    _resetSafetyStabilizer();
    _lastActuatorCommand = null;
    await applySafetyActuatorState('SAFE');
    notifyListeners();
  }

  @override
  void dispose() {
    _freshnessTimer.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _forwarder?.dispose();
    _api?.dispose();
    unawaited(ble.dispose());
    super.dispose();
  }
}
