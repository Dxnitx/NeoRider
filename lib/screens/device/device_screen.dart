import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../models/ble_sensor_reading.dart';
import '../../models/neorider_sensor_pair.dart';
import '../../models/prediction_result.dart';
import '../../models/safety_status.dart';
import '../../services/api_service.dart';
import '../../services/ble_service.dart';
import '../../services/safety_service.dart';
import '../../services/safety_feedback_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/safety_status_card.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});
  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  static const green = Color(0xFF24B53A);
  static const dark = Color(0xFF02111D);
  final _ble = NeoRiderBleService();
  final _api = NeoRiderApiService();
  late final BleSafetyFeedbackController _feedback;
  late final NeoRiderSafetyService _safety;
  late final NeoRiderPairForwarder _forwarder;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  NeoRiderBleState _state = NeoRiderBleState.disconnected;
  BluetoothAdapterState _adapter = FlutterBluePlus.adapterStateNow;
  BleSensorReading? _helmet;
  BleSensorReading? _chest;
  BackendResult? _backend;
  String _backendConnection = 'DISCONNECTED';
  String _backendStatus = 'Waiting for synchronized sensor data';
  int? _lastSentSequence;
  SafetyStatus _safetyStatus = SafetyStatus.waiting();
  bool _accidentAlertVisible = false;
  SafetyFeedbackSnapshot _feedbackSnapshot = const SafetyFeedbackSnapshot();

  @override
  void initState() {
    super.initState();
    _feedback = BleSafetyFeedbackController(_ble);
    _safety = NeoRiderSafetyService(feedback: _feedback);
    _forwarder = NeoRiderPairForwarder(
      api: _api,
      onSent: _pairSent,
      onFailure: _pairFailed,
    );
    _subscriptions.addAll([
      _ble.stateStream.listen((v) => _refresh(() => _state = v)),
      _ble.adapterStateStream.listen((v) => _refresh(() => _adapter = v)),
      _ble.helmetStream.listen((v) {
        _refresh(() => _helmet = v);
      }),
      _ble.chestStream.listen((v) {
        _refresh(() => _chest = v);
      }),
      _ble.pairStream.listen(_queuePair),
      _safety.statusStream.listen(
        (value) => _refresh(() => _safetyStatus = value),
      ),
      _safety.transitionStream.listen(_handleSafetyTransition),
      _feedback.snapshotStream.listen(
        (value) => _refresh(() => _feedbackSnapshot = value),
      ),
    ]);
  }

  void _queuePair(NeoRiderSensorPair pair) {
    _forwarder.enqueue(pair);
  }

  void _pairSent(NeoRiderSensorPair pair, BackendResult result) {
    if (!mounted) return;
    final displayedResult = result.isCollecting && _backend != null
        ? BackendResult(
            status: result.status,
            rideId: result.rideId,
            helmetBufferSize: result.helmetBufferSize,
            chestBufferSize: result.chestBufferSize,
            pairedBufferSize: result.pairedBufferSize,
            requiredReadings: result.requiredReadings,
            finalState: _backend!.finalState,
            accidentStreak: result.accidentStreak ?? _backend!.accidentStreak,
            impactGatePassed:
                result.impactGatePassed ?? _backend!.impactGatePassed,
            isHelmetStationary:
                result.isHelmetStationary ?? _backend!.isHelmetStationary,
            isChestStationary:
                result.isChestStationary ?? _backend!.isChestStationary,
            bothStationary: result.bothStationary ?? _backend!.bothStationary,
            fusedPrediction:
                result.fusedPrediction ?? _backend!.fusedPrediction,
            fusedConfidence:
                result.fusedConfidence ?? _backend!.fusedConfidence,
            prediction: _backend!.prediction,
          )
        : result;
    _refresh(() {
      _backend = displayedResult;
      _backendConnection = 'CONNECTED';
      _backendStatus = result.status;
      _lastSentSequence = pair.sequence;
    });
    final finalState = result.finalState;
    if (!result.isCollecting && finalState != null) {
      _safety.receiveFinalState(
        finalState,
        prediction: result.prediction,
        rideId: result.rideId,
        sequence: pair.sequence,
      );
    }
  }

  void _pairFailed(NeoRiderSensorPair pair, Object error) {
    _backendError('Backend unavailable for sequence ${pair.sequence}: $error');
  }

  void _handleSafetyTransition(SafetyTransition transition) {
    if (!mounted) return;
    switch (transition.current.state) {
      case RiderSafetyState.risk:
        debugPrint('[ALERT] Risk warning displayed');
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
              content: const Text(
                'Risk Detected\nUnsafe riding behaviour detected. Reduce speed and stabilize your posture.',
              ),
            ),
          );
        return;
      case RiderSafetyState.accident:
        if (_accidentAlertVisible) return;
        _accidentAlertVisible = true;
        debugPrint('[ALERT] Accident alert displayed');
        unawaited(_showAccidentAlert(transition.current));
        return;
      case RiderSafetyState.safe:
      case RiderSafetyState.unknown:
        return;
    }
  }

  Future<void> _showAccidentAlert(SafetyStatus status) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.emergency, color: Colors.red, size: 48),
        title: const Text(
          'POSSIBLE ACCIDENT DETECTED',
          textAlign: TextAlign.center,
        ),
        content: Text(status.message, textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("I'm OK"),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Emergency services are not connected in this development build.',
                  ),
                ),
              );
            },
            child: const Text('Emergency'),
          ),
        ],
      ),
    );
    _accidentAlertVisible = false;
  }

  void _backendError(String message) {
    debugPrint('[API] $message');
    _refresh(() {
      _backendConnection = 'DISCONNECTED';
      _backendStatus = message;
    });
  }

  Future<void> _checkBackend() async {
    _refresh(() => _backendStatus = 'Checking backend...');
    try {
      await _api.checkHealth();
      _refresh(() {
        _backendConnection = 'CONNECTED';
        _backendStatus = 'Backend reachable';
      });
    } catch (error) {
      _backendError('Backend unavailable: $error');
    }
  }

  void _refresh(VoidCallback update) {
    if (mounted) setState(update);
  }

  bool get _busy =>
      _state == NeoRiderBleState.scanning ||
      _state == NeoRiderBleState.connecting;
  bool get _connected => _state == NeoRiderBleState.connected;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _forwarder.dispose();
    _api.dispose();
    unawaited(_safety.dispose());
    unawaited(_feedback.dispose());
    unawaited(_ble.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    final gap = SizedBox(height: responsive.sectionSpacing);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        title: const Text('Helmet & Device'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(responsive.horizontalPadding),
        children: [
          _Section(
            title: 'Bluetooth',
            icon: Icons.bluetooth,
            children: [
              _Status(
                label: 'Bluetooth Adapter',
                value: _adapter == BluetoothAdapterState.on ? 'ON' : 'OFF',
                color: _adapter == BluetoothAdapterState.on
                    ? green
                    : Colors.grey,
              ),
            ],
          ),
          gap,
          _Section(
            title: 'Helmet Device',
            icon: Icons.sports_motorsports,
            children: [
              const _Info(
                label: 'Device Name',
                value: NeoRiderBleService.deviceName,
              ),
              _Info(label: 'Status', value: _ble.status),
              _Info(
                label: 'Device Address',
                value: _ble.connectedDeviceId ?? '--',
              ),
            ],
          ),
          gap,
          _Section(
            title: 'Connection',
            icon: Icons.settings_input_antenna,
            children: [
              _Status(
                label: 'BLE Connection',
                value: _connected ? 'CONNECTED' : 'DISCONNECTED',
                color: _connected ? green : Colors.grey,
              ),
              _Info(
                label: 'GATT Services',
                value: '${_ble.gattServiceCount} FOUND',
              ),
              if (_busy) const LinearProgressIndicator(color: green),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy || _connected ? null : _ble.scanForDevice,
                    icon: const Icon(Icons.search),
                    label: const Text('Scan for Helmet'),
                  ),
                  FilledButton.icon(
                    onPressed: _busy || _connected || !_ble.hasDiscoveredDevice
                        ? null
                        : _ble.connect,
                    icon: const Icon(Icons.bluetooth_connected),
                    label: const Text('Connect'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _connected && !_busy ? _ble.disconnect : null,
                    icon: const Icon(Icons.bluetooth_disabled),
                    label: const Text('Disconnect'),
                  ),
                ],
              ),
            ],
          ),
          gap,
          _Sensor(title: 'Helmet Sensor', reading: _helmet),
          gap,
          _Sensor(title: 'Chest Sensor', reading: _chest),
          gap,
          _Section(
            title: 'Backend',
            icon: Icons.cloud_outlined,
            children: [
              _Status(
                label: 'Connection',
                value: _backendConnection,
                color: _backendConnection == 'CONNECTED' ? green : Colors.grey,
              ),
              _Info(label: 'Status', value: _backendStatus),
              _Info(label: 'Ride ID', value: _backend?.rideId ?? _api.rideId),
              _Buffer(
                label: 'Helmet Buffer',
                value: _backend?.helmetBufferSize,
                required: _backend?.requiredReadings ?? 20,
              ),
              _Buffer(
                label: 'Chest Buffer',
                value: _backend?.chestBufferSize,
                required: _backend?.requiredReadings ?? 20,
              ),
              _Buffer(
                label: 'Paired Buffer',
                value: _backend?.pairedBufferSize,
                required: _backend?.requiredReadings ?? 20,
              ),
              _Info(
                label: 'Last Sent Sequence',
                value: _lastSentSequence?.toString() ?? '--',
              ),
              TextButton.icon(
                onPressed: _checkBackend,
                icon: const Icon(Icons.refresh),
                label: const Text('Check Backend'),
              ),
            ],
          ),
          if (_backend != null) ...[gap, _SafetyResult(result: _backend!)],
          gap,
          SafetyStatusCard(status: _safetyStatus),
          gap,
          _Section(
            title: 'Hardware Feedback',
            icon: Icons.vibration,
            children: [
              _Status(
                label: 'Control Channel',
                value: _feedback.canSend ? 'READY' : 'UNAVAILABLE',
                color: _feedback.canSend ? green : Colors.grey,
              ),
              _Info(
                label: 'Last Feedback',
                value:
                    _feedbackSnapshot.lastCommand?.name.toUpperCase() ?? '--',
              ),
              _Info(
                label: 'Last Command Status',
                value: _feedbackSnapshot.status.name.capitalize(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _DeviceScreenState.green, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

class _Sensor extends StatelessWidget {
  const _Sensor({required this.title, required this.reading});
  final String title;
  final BleSensorReading? reading;
  @override
  Widget build(BuildContext context) => _Section(
    title: title,
    icon: title.startsWith('Helmet')
        ? Icons.sports_motorsports
        : Icons.accessibility_new,
    children: [
      _Status(
        label: 'Stream',
        value: reading == null ? 'WAITING' : 'LIVE',
        color: reading == null ? Colors.grey : _DeviceScreenState.green,
      ),
      _Info(label: 'Sequence', value: reading?.sequence.toString() ?? '--'),
      _Vector(
        title: 'Accel',
        x: reading?.accelX,
        y: reading?.accelY,
        z: reading?.accelZ,
      ),
      _Vector(
        title: 'Gyro',
        x: reading?.gyroX,
        y: reading?.gyroY,
        z: reading?.gyroZ,
      ),
      const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Orientation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      _Info(label: 'Pitch', value: _number(reading?.pitch)),
      _Info(label: 'Roll', value: _number(reading?.roll)),
      _Info(label: 'Yaw', value: _number(reading?.yaw)),
    ],
  );
}

class _Vector extends StatelessWidget {
  const _Vector({required this.title, this.x, this.y, this.z});
  final String title;
  final double? x, y, z;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [_axis('X', x), _axis('Y', y), _axis('Z', z)]),
      ],
    ),
  );
  Widget _axis(String label, double? value) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            _number(value),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class _SafetyResult extends StatelessWidget {
  const _SafetyResult({required this.result});
  final BackendResult result;

  String get safetyLabel => switch (result.finalState?.toUpperCase()) {
    'SAFE' => 'SAFE',
    'RISK' => 'RISK',
    'ACCIDENT_PENDING' => 'ACCIDENT PENDING',
    'ACCIDENT_CONFIRMED' => 'ACCIDENT',
    _ => 'UNKNOWN',
  };

  @override
  Widget build(BuildContext context) {
    final color = switch (result.finalState?.toUpperCase()) {
      'SAFE' => _DeviceScreenState.green,
      'RISK' || 'ACCIDENT_PENDING' => Colors.orange,
      'ACCIDENT_CONFIRMED' => Colors.red,
      _ => Colors.grey,
    };
    return _Card(
      color: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety State',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            safetyLabel,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          _Info(label: 'Backend Status', value: result.status.toUpperCase()),
          _Info(
            label: result.isCollecting
                ? 'Last Raw ML Prediction'
                : 'Raw ML Prediction',
            value: result.fusedPrediction ?? 'Waiting for prediction',
          ),
          _Info(
            label: result.isCollecting
                ? 'Last Raw ML Confidence'
                : 'Raw ML Confidence',
            value: result.fusedConfidence?.toStringAsFixed(3) ?? '--',
          ),
          _Info(
            label: 'Both Stationary',
            value: result.bothStationary == null
                ? 'UNKNOWN'
                : result.bothStationary!
                ? 'YES'
                : 'NO',
          ),
          _Info(
            label: 'Impact Gate',
            value: result.impactGatePassed == null
                ? 'UNKNOWN'
                : result.impactGatePassed!
                ? 'PASS'
                : 'FAIL',
          ),
          _Info(
            label: 'Accident Streak',
            value: '${result.accidentStreak ?? 0} / 3',
          ),
          if (result.prediction?.modelUsed != null)
            _Info(label: 'Model', value: result.prediction!.modelUsed!),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _Buffer extends StatelessWidget {
  const _Buffer({
    required this.label,
    required this.value,
    required this.required,
  });
  final String label;
  final int? value;
  final int required;
  @override
  Widget build(BuildContext context) => _Info(
    label: label,
    value: value == null ? '-- / $required' : '$value / $required',
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.color = Colors.white,
    this.borderColor,
  });
  final Widget child;
  final Color color;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
      border: borderColor == null ? null : Border.all(color: borderColor!),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
      ],
    ),
    child: child,
  );
}

String _number(double? value) => value?.toStringAsFixed(2) ?? '--';

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
