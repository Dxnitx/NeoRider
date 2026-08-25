import 'dart:async';

import 'package:flutter/material.dart';

import '../models/ble_sensor_reading.dart';
import '../models/neorider_sensor_pair.dart';
import '../services/ble_service.dart';
import '../utils/responsive.dart';

class BleTestScreen extends StatefulWidget {
  const BleTestScreen({super.key});

  @override
  State<BleTestScreen> createState() => _BleTestScreenState();
}

class _BleTestScreenState extends State<BleTestScreen> {
  final NeoRiderBleService _ble = NeoRiderBleService();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  NeoRiderBleState _state = NeoRiderBleState.idle;
  BleSensorReading? _helmet;
  BleSensorReading? _chest;
  NeoRiderSensorPair? _pair;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      _ble.stateStream.listen((state) => _refresh(() => _state = state)),
      _ble.helmetStream.listen((value) => _refresh(() => _helmet = value)),
      _ble.chestStream.listen((value) => _refresh(() => _chest = value)),
      _ble.pairStream.listen((value) => _refresh(() => _pair = value)),
    ]);
  }

  void _refresh(VoidCallback update) {
    if (!mounted) return;
    setState(update);
  }

  bool get _connectEnabled => !{
    NeoRiderBleState.scanning,
    NeoRiderBleState.connecting,
    NeoRiderBleState.connected,
  }.contains(_state);

  bool get _disconnectEnabled => {
    NeoRiderBleState.scanning,
    NeoRiderBleState.connecting,
    NeoRiderBleState.connected,
  }.contains(_state);

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _ble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00131D),
        foregroundColor: Colors.white,
        title: const Text('NeoRider BLE Test'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusCard(state: _state, status: _ble.status),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _connectEnabled ? _ble.scanAndConnect : null,
                      icon: const Icon(Icons.bluetooth_searching),
                      label: const Text('Connect'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: const Color(0xFF39D353),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _disconnectEnabled ? _ble.disconnect : null,
                      icon: const Icon(Icons.bluetooth_disabled),
                      label: const Text('Disconnect'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PairCard(pair: _pair),
              const SizedBox(height: 16),
              _ReadingCard(title: 'Helmet IMU', reading: _helmet),
              const SizedBox(height: 16),
              _ReadingCard(title: 'Chest IMU', reading: _chest),
              SizedBox(height: responsive.sectionSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state, required this.status});
  final NeoRiderBleState state;
  final String status;

  @override
  Widget build(BuildContext context) {
    final connected = state == NeoRiderBleState.connected;
    return _Card(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: connected
                ? const Color(0xFF39D353).withValues(alpha: 0.15)
                : Colors.blueGrey.withValues(alpha: 0.12),
            child: Icon(
              connected ? Icons.bluetooth_connected : Icons.bluetooth,
              color: connected ? const Color(0xFF1A9B31) : Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PairCard extends StatelessWidget {
  const _PairCard({required this.pair});
  final NeoRiderSensorPair? pair;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synchronized Pair',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          pair == null
              ? 'Waiting for matching Helmet + Chest packets'
              : 'Pair #${pair!.sequence} ready',
        ),
        if (pair != null) Text('Received: ${pair!.receivedAt.toLocal()}'),
      ],
    ),
  );
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.title, required this.reading});
  final String title;
  final BleSensorReading? reading;

  @override
  Widget build(BuildContext context) {
    final value = reading;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (value == null)
            const Text('No sensor packet received yet')
          else ...[
            Text(
              'Sequence: ${value.sequence}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _ValueRow(
              label: 'Acceleration (m/s²)',
              values: [value.accelX, value.accelY, value.accelZ],
            ),
            _ValueRow(
              label: 'Gyroscope (deg/s)',
              values: [value.gyroX, value.gyroY, value.gyroZ],
            ),
            _ValueRow(
              label: 'Angles (degrees)',
              values: [value.pitch, value.roll, value.yaw],
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.values});
  final String label;
  final List<double> values;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 3),
        Text(
          'X ${values[0].toStringAsFixed(2)}   Y ${values[1].toStringAsFixed(2)}   Z ${values[2].toStringAsFixed(2)}',
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
      ],
    ),
    child: child,
  );
}
