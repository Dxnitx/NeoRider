import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/ble_sensor_reading.dart';
import '../models/neorider_sensor_pair.dart';
import '../models/safety_control.dart';

enum NeoRiderBleState {
  idle,
  scanning,
  deviceFound,
  connecting,
  connected,
  disconnected,
  bluetoothOff,
  error,
}

class NeoRiderBleService {
  NeoRiderBleService() {
    debugPrint('[BLE] BLE SERVICE INITIALIZED');
    _metricsTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _logMetrics(),
    );
  }

  static const deviceName = 'NeoRider-Helmet';
  static final serviceUuid = Guid('6e400001-b5a3-f393-e0a9-e50e24dcca9e');
  static final helmetUuid = Guid('6e400003-b5a3-f393-e0a9-e50e24dcca9e');
  static final chestUuid = Guid('6e400004-b5a3-f393-e0a9-e50e24dcca9e');
  static final safetyControlUuid = Guid('6e400005-b5a3-f393-e0a9-e50e24dcca9e');
  static const packetLength = 20;
  static const maxPendingPackets = 32;

  final _stateController = StreamController<NeoRiderBleState>.broadcast();
  final _helmetController = StreamController<BleSensorReading>.broadcast();
  final _chestController = StreamController<BleSensorReading>.broadcast();
  final _pairController = StreamController<NeoRiderSensorPair>.broadcast();
  final _adapterController =
      StreamController<BluetoothAdapterState>.broadcast();

  final Map<int, BleSensorReading> _pendingHelmet = {};
  final Map<int, BleSensorReading> _pendingChest = {};

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _helmetSubscription;
  StreamSubscription<List<int>>? _chestSubscription;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _helmetCharacteristic;
  BluetoothCharacteristic? _chestCharacteristic;
  BluetoothCharacteristic? _controlCharacteristic;
  Future<BluetoothCharacteristic?>? _controlRediscovery;
  bool _controlRefreshAttempted = false;
  bool _operationActive = false;
  bool _manualDisconnect = false;
  bool _disposed = false;
  Timer? _metricsTimer;
  int helmetPacketsReceived = 0;
  int chestPacketsReceived = 0;
  int matchedPairsCreated = 0;
  int _helmetAtLastLog = 0;
  int _chestAtLastLog = 0;
  int _pairsAtLastLog = 0;

  NeoRiderBleState state = NeoRiderBleState.disconnected;
  String status = 'Disconnected';
  String? safetyState;
  BleSensorReading? latestHelmet;
  BleSensorReading? latestChest;
  NeoRiderSensorPair? latestPair;
  BluetoothAdapterState adapterState = FlutterBluePlus.adapterStateNow;
  int gattServiceCount = 0;

  Stream<NeoRiderBleState> get stateStream => _stateController.stream;
  Stream<BleSensorReading> get helmetStream => _helmetController.stream;
  Stream<BleSensorReading> get chestStream => _chestController.stream;
  Stream<NeoRiderSensorPair> get pairStream => _pairController.stream;
  Stream<BluetoothAdapterState> get adapterStateStream =>
      _adapterController.stream;
  String? get connectedDeviceName => _device?.platformName;
  String? get connectedDeviceId => _device?.remoteId.toString();
  bool get hasDiscoveredDevice => _device != null;
  BluetoothCharacteristic? get controlCharacteristic => _controlCharacteristic;
  bool get canSendSafetyFeedback {
    final characteristic = _controlCharacteristic;
    return state == NeoRiderBleState.connected &&
        characteristic != null &&
        (characteristic.properties.write ||
            characteristic.properties.writeWithoutResponse);
  }

  Future<void> scanAndConnect() => _scan(connectAfterScan: true);

  Future<void> scanForDevice() => _scan(connectAfterScan: false);

  Future<void> _scan({required bool connectAfterScan}) async {
    if (_disposed || _operationActive || state == NeoRiderBleState.connected) {
      return;
    }
    _operationActive = true;
    _manualDisconnect = false;

    try {
      _ensureAdapterListener();
      await _stopScanAndListener();
      await _cancelConnectionSubscription();
      await _clearGattSubscriptions();

      if (!await FlutterBluePlus.isSupported) {
        _updateState(
          NeoRiderBleState.error,
          'BLE is not supported on this device',
        );
        return;
      }

      var adapterState = await FlutterBluePlus.adapterState.first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => FlutterBluePlus.adapterStateNow,
      );
      if (adapterState == BluetoothAdapterState.unknown) {
        adapterState = await FlutterBluePlus.adapterState
            .firstWhere((value) => value != BluetoothAdapterState.unknown)
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () => FlutterBluePlus.adapterStateNow,
            );
      }
      if (adapterState != BluetoothAdapterState.on) {
        final unauthorized = adapterState == BluetoothAdapterState.unauthorized;
        _updateState(
          unauthorized ? NeoRiderBleState.error : NeoRiderBleState.bluetoothOff,
          unauthorized
              ? 'Bluetooth permission is not authorized'
              : 'Bluetooth is turned off',
        );
        return;
      }

      _updateState(
        NeoRiderBleState.scanning,
        'Scanning for NeoRider helmet...',
      );
      _log('SCAN STARTED');
      final foundDevice = Completer<BluetoothDevice>();
      _scanSubscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          if (foundDevice.isCompleted) return;
          for (final result in results) {
            if (result.advertisementData.advName == deviceName) {
              _log(
                'DEVICE FOUND: ${result.advertisementData.advName} '
                '(${result.device.remoteId})',
              );
              foundDevice.complete(result.device);
              break;
            }
          }
        },
        onError: (Object error) {
          if (!foundDevice.isCompleted) foundDevice.completeError(error);
        },
      );

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        androidUsesFineLocation: false,
      );

      BluetoothDevice device;
      try {
        device = await foundDevice.future.timeout(const Duration(seconds: 13));
      } on TimeoutException {
        _updateState(NeoRiderBleState.error, 'NeoRider helmet not found');
        return;
      } finally {
        await _stopScanAndListener();
      }

      _device = device;
      if (connectAfterScan) {
        await _connectFoundDevice(device);
      } else {
        _updateState(NeoRiderBleState.deviceFound, '$deviceName found');
      }
    } catch (error, stackTrace) {
      final message = _friendlyError(error);
      _log('BLE ERROR: $message');
      debugPrintStack(stackTrace: stackTrace);
      _updateState(NeoRiderBleState.error, message);
      await _clearGattSubscriptions();
      await _cancelConnectionSubscription();
      await _disconnectDeviceSilently();
    } finally {
      _operationActive = false;
    }
  }

  Future<void> connect() async {
    if (_disposed || _operationActive || state == NeoRiderBleState.connected) {
      return;
    }
    final device = _device;
    if (device == null) {
      _updateState(NeoRiderBleState.error, 'Scan for NeoRider helmet first');
      return;
    }
    _operationActive = true;
    _manualDisconnect = false;
    try {
      await _connectFoundDevice(device);
    } catch (error, stackTrace) {
      final message = _friendlyError(error);
      _log('BLE ERROR: $message');
      debugPrintStack(stackTrace: stackTrace);
      _updateState(
        NeoRiderBleState.disconnected,
        'Connection failed: $message',
      );
      await _clearGattSubscriptions();
      await _cancelConnectionSubscription();
      await _disconnectDeviceSilently();
    } finally {
      _operationActive = false;
    }
  }

  Future<void> _connectFoundDevice(BluetoothDevice device) async {
    await _cancelConnectionSubscription();
    await _clearGattSubscriptions();
    _listenForDisconnection(device);
    _updateState(NeoRiderBleState.connecting, 'Connecting to $deviceName...');
    _log('CONNECT STARTED');
    await device.connect(
      license: License.nonprofit,
      timeout: const Duration(seconds: 15),
    );
    _log('CONNECTED');
    _controlRefreshAttempted = false;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      debugPrint('[BLE][GATT] clearing Android cache');
      try {
        await device.clearGattCache();
        debugPrint('[BLE][GATT] cache cleared');
      } catch (error, stackTrace) {
        debugPrint('[BLE][GATT][ERROR] cache clear failed: $error');
        debugPrint('$stackTrace');
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    debugPrint('[BLE][GATT] discovering fresh services');
    await _discoverAndSubscribe(device);
  }

  void _ensureAdapterListener() {
    _adapterSubscription ??= FlutterBluePlus.adapterState.listen((
      adapterState,
    ) {
      this.adapterState = adapterState;
      if (!_adapterController.isClosed) _adapterController.add(adapterState);
      if (adapterState == BluetoothAdapterState.on ||
          adapterState == BluetoothAdapterState.unknown) {
        return;
      }
      if (state == NeoRiderBleState.idle || state == NeoRiderBleState.error) {
        return;
      }
      final unauthorized = adapterState == BluetoothAdapterState.unauthorized;
      _updateState(
        unauthorized ? NeoRiderBleState.error : NeoRiderBleState.bluetoothOff,
        unauthorized
            ? 'Bluetooth permission is not authorized'
            : 'Bluetooth is turned off',
      );
      _stopScanAndListener();
      _clearGattSubscriptions();
    });
  }

  void _listenForDisconnection(BluetoothDevice device) {
    _connectionSubscription = device.connectionState.listen((connectionState) {
      if (connectionState != BluetoothConnectionState.disconnected) return;
      _log('Disconnected: ${device.disconnectReason}');
      _controlCharacteristic = null;
      _clearGattSubscriptions();
      if (!_manualDisconnect && state != NeoRiderBleState.scanning) {
        _updateState(
          NeoRiderBleState.disconnected,
          'NeoRider helmet disconnected',
        );
      }
    });
  }

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    _controlCharacteristic = null;
    final services = await device.discoverServices();
    gattServiceCount = services.length;
    BluetoothService? targetService;
    for (final service in services) {
      if (service.uuid == serviceUuid) {
        targetService = service;
        break;
      }
    }
    if (targetService == null) {
      throw StateError('NeoRider BLE service not found');
    }
    _log('SERVICES DISCOVERED');

    final discoveredUuids = <String>[];
    for (final characteristic in targetService.characteristics) {
      final uuid = characteristic.uuid.toString();
      discoveredUuids.add(uuid);
      debugPrint(
        '[BLE][DISCOVERY] uuid=$uuid '
        'write=${characteristic.properties.write} '
        'writeWithoutResponse=${characteristic.properties.writeWithoutResponse} '
        'notify=${characteristic.properties.notify}',
      );
      if (characteristic.uuid == helmetUuid) {
        _helmetCharacteristic = characteristic;
        _log('HELMET CHARACTERISTIC FOUND');
      } else if (characteristic.uuid == chestUuid) {
        _chestCharacteristic = characteristic;
        _log('CHEST CHARACTERISTIC FOUND');
      } else if (characteristic.uuid == safetyControlUuid) {
        _controlCharacteristic = characteristic;
        debugPrint(
          '[BLE][CONTROL] characteristic found uuid=${characteristic.uuid}',
        );
        debugPrint(
          '[BLE][CONTROL] write=${characteristic.properties.write} '
          'writeWithoutResponse='
          '${characteristic.properties.writeWithoutResponse}',
        );
      }
    }
    if (_controlCharacteristic == null) {
      debugPrint('[BLE][CONTROL] characteristic NOT FOUND after discovery');
      for (final uuid in discoveredUuids) {
        debugPrint('[BLE][CONTROL][ERROR] discovered uuid=$uuid');
      }
    }
    if (_helmetCharacteristic == null) {
      throw StateError('Helmet characteristic not found');
    }
    if (_chestCharacteristic == null) {
      throw StateError('Chest characteristic not found');
    }

    _helmetSubscription = _helmetCharacteristic!.onValueReceived.listen(
      (value) => _handlePacket(value, isHelmet: true),
    );
    _chestSubscription = _chestCharacteristic!.onValueReceived.listen(
      (value) => _handlePacket(value, isHelmet: false),
    );
    await _helmetCharacteristic!.setNotifyValue(true);
    _log('Helmet notifications enabled');
    await _chestCharacteristic!.setNotifyValue(true);
    _log('Chest notifications enabled');
    _updateState(NeoRiderBleState.connected, 'Connected');
  }

  /// Writes one idempotent control byte on the optional hardware-feedback
  /// channel. Failure is isolated from sensor notification subscriptions.
  Future<bool> sendSafetyCommand(SafetyControlCommand command) async {
    final characteristic = _controlCharacteristic;
    if (state != NeoRiderBleState.connected || characteristic == null) {
      debugPrint('[BLE][CONTROL] write failed: channel unavailable');
      return false;
    }
    final supportsWithoutResponse =
        characteristic.properties.writeWithoutResponse;
    if (!supportsWithoutResponse && !characteristic.properties.write) {
      debugPrint('[BLE][CONTROL] write failed: characteristic is not writable');
      return false;
    }
    try {
      debugPrint(
        '[BLE][CONTROL][WRITE] uuid=${characteristic.uuid} '
        'command=${command.hex}',
      );
      await characteristic.write([
        command.byteValue,
      ], withoutResponse: supportsWithoutResponse);
      debugPrint('[BLE][CONTROL][WRITE] success command=${command.hex}');
      return true;
    } catch (error, stackTrace) {
      debugPrint(
        '[BLE][CONTROL][WRITE] failed command=${command.hex} error=$error',
      );
      debugPrint('$stackTrace');
      return false;
    }
  }

  /// Refreshes only the cached control characteristic on the existing
  /// connection. Sensor listeners and notification subscriptions are untouched.
  Future<BluetoothCharacteristic?> refreshControlCharacteristic() async {
    final cached = _controlCharacteristic;
    if (cached != null) return cached;

    final pending = _controlRediscovery;
    if (pending != null) return pending;
    if (_controlRefreshAttempted) return null;

    _controlRefreshAttempted = true;
    final refresh = _rediscoverControlCharacteristic();
    _controlRediscovery = refresh;
    try {
      return await refresh;
    } finally {
      if (identical(_controlRediscovery, refresh)) {
        _controlRediscovery = null;
      }
    }
  }

  Future<BluetoothCharacteristic?> _rediscoverControlCharacteristic() async {
    final device = _device;
    if (device == null || state != NeoRiderBleState.connected) return null;

    final services = await device.discoverServices();
    final targetService = services
        .where((service) => service.uuid == serviceUuid)
        .firstOrNull;
    if (targetService == null) {
      debugPrint('[BLE][CONTROL][ERROR] NeoRider service NOT FOUND');
      return null;
    }

    for (final characteristic in targetService.characteristics) {
      debugPrint(
        '[BLE][DISCOVERY] uuid=${characteristic.uuid} '
        'write=${characteristic.properties.write} '
        'writeWithoutResponse=${characteristic.properties.writeWithoutResponse} '
        'notify=${characteristic.properties.notify}',
      );
      if (characteristic.uuid == safetyControlUuid) {
        _controlCharacteristic = characteristic;
        debugPrint(
          '[BLE][CONTROL] characteristic found uuid=${characteristic.uuid}',
        );
        debugPrint(
          '[BLE][CONTROL] write=${characteristic.properties.write} '
          'writeWithoutResponse='
          '${characteristic.properties.writeWithoutResponse}',
        );
      }
    }

    if (_controlCharacteristic == null) {
      debugPrint('[BLE][CONTROL] characteristic NOT FOUND after discovery');
      for (final characteristic in targetService.characteristics) {
        debugPrint(
          '[BLE][CONTROL][ERROR] discovered uuid=${characteristic.uuid} '
          'write=${characteristic.properties.write} '
          'writeWithoutResponse=${characteristic.properties.writeWithoutResponse} '
          'notify=${characteristic.properties.notify}',
        );
      }
    }
    return _controlCharacteristic;
  }

  void _handlePacket(List<int> value, {required bool isHelmet}) {
    final source = isHelmet ? 'HELMET' : 'CHEST';
    if (value.length != packetLength) {
      _log(
        '$source malformed packet: received ${value.length} bytes, expected $packetLength',
      );
      return;
    }
    final reading = _decodePacket(value);
    if (isHelmet) {
      helmetPacketsReceived++;
      latestHelmet = reading;
      _pendingHelmet[reading.sequence] = reading;
      if (!_helmetController.isClosed) _helmetController.add(reading);
    } else {
      chestPacketsReceived++;
      latestChest = reading;
      _pendingChest[reading.sequence] = reading;
      if (!_chestController.isClosed) _chestController.add(reading);
    }
    _createPairIfReady(reading.sequence);
    _trimPending(_pendingHelmet);
    _trimPending(_pendingChest);
  }

  BleSensorReading _decodePacket(List<int> value) {
    if (value.length != packetLength) {
      throw FormatException(
        'Invalid NeoRider packet length: ${value.length}; expected $packetLength',
      );
    }
    final data = ByteData.sublistView(Uint8List.fromList(value));
    return BleSensorReading(
      accelX: data.getInt16(0, Endian.little) / 100.0,
      accelY: data.getInt16(2, Endian.little) / 100.0,
      accelZ: data.getInt16(4, Endian.little) / 100.0,
      gyroX: data.getInt16(6, Endian.little) / 10.0,
      gyroY: data.getInt16(8, Endian.little) / 10.0,
      gyroZ: data.getInt16(10, Endian.little) / 10.0,
      pitch: data.getInt16(12, Endian.little) / 100.0,
      roll: data.getInt16(14, Endian.little) / 100.0,
      yaw: data.getInt16(16, Endian.little) / 100.0,
      sequence: data.getUint16(18, Endian.little),
    );
  }

  void _createPairIfReady(int sequence) {
    final helmet = _pendingHelmet[sequence];
    final chest = _pendingChest[sequence];
    if (helmet == null || chest == null) return;
    _pendingHelmet.remove(sequence);
    _pendingChest.remove(sequence);
    final pair = NeoRiderSensorPair(
      sequence: sequence,
      helmet: helmet,
      chest: chest,
      receivedAt: DateTime.now(),
    );
    latestPair = pair;
    matchedPairsCreated++;
    if (!_pairController.isClosed) _pairController.add(pair);
  }

  void _trimPending(Map<int, BleSensorReading> pending) {
    while (pending.length > maxPendingPackets) {
      pending.remove(pending.keys.first);
    }
  }

  void _logMetrics() {
    final helmetRate = helmetPacketsReceived - _helmetAtLastLog;
    final chestRate = chestPacketsReceived - _chestAtLastLog;
    final pairRate = matchedPairsCreated - _pairsAtLastLog;
    _helmetAtLastLog = helmetPacketsReceived;
    _chestAtLastLog = chestPacketsReceived;
    _pairsAtLastLog = matchedPairsCreated;
    debugPrint(
      '[BLE][1s] helmetPackets=$helmetRate chestPackets=$chestRate '
      'matchedPairs=$pairRate totals=($helmetPacketsReceived,'
      '$chestPacketsReceived,$matchedPairsCreated)',
    );
  }

  void _updateState(NeoRiderBleState newState, String message) {
    state = newState;
    status = message;
    _log(message);
    if (!_stateController.isClosed) _stateController.add(newState);
  }

  String _friendlyError(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('permission') || lower.contains('unauthorized')) {
      return 'Bluetooth permission denied. Allow Nearby devices and try again.';
    }
    if (raw.startsWith('Bad state: ')) {
      return raw.substring('Bad state: '.length);
    }
    return raw;
  }

  Future<void> disconnect() async {
    if (_disposed) return;
    _manualDisconnect = true;
    _controlCharacteristic = null;
    await _stopScanAndListener();
    await _clearGattSubscriptions();
    final device = _device;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (error) {
        _log('Disconnect error: $error');
      }
    }
    await _cancelConnectionSubscription();
    _device = null;
    gattServiceCount = 0;
    _pendingHelmet.clear();
    _pendingChest.clear();
    _operationActive = false;
    _updateState(NeoRiderBleState.disconnected, 'Disconnected');
  }

  Future<void> _stopScanAndListener() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    } catch (error) {
      _log('Stop scan error: $error');
    }
  }

  Future<void> _clearGattSubscriptions() async {
    await _helmetSubscription?.cancel();
    await _chestSubscription?.cancel();
    _helmetSubscription = null;
    _chestSubscription = null;
    _helmetCharacteristic = null;
    _chestCharacteristic = null;
  }

  Future<void> _cancelConnectionSubscription() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }

  Future<void> _disconnectDeviceSilently() async {
    final device = _device;
    _device = null;
    if (device == null) return;
    try {
      await device.disconnect();
    } catch (error) {
      _log('Connection cleanup error: $error');
    }
  }

  void _log(String message) => debugPrint('[BLE] $message');

  Future<void> dispose() async {
    if (_disposed) return;
    await disconnect();
    _disposed = true;
    _metricsTimer?.cancel();
    _metricsTimer = null;
    await _adapterSubscription?.cancel();
    _adapterSubscription = null;
    await _stateController.close();
    await _helmetController.close();
    await _chestController.close();
    await _pairController.close();
    await _adapterController.close();
  }
}
