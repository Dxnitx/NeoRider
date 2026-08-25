import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'config/api_config.dart';

class NeoRiderSensorPacket {
  const NeoRiderSensorPacket({
    required this.sequence,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.pitch,
    required this.roll,
    required this.yaw,
  });

  final int sequence;
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;
  final double pitch;
  final double roll;
  final double yaw;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeoRiderBleTestApp());
}

class NeoRiderBleTestApp extends StatelessWidget {
  const NeoRiderBleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const BleTestPage(),
    );
  }
}

class BleTestPage extends StatefulWidget {
  const BleTestPage({super.key});

  @override
  State<BleTestPage> createState() => _BleTestPageState();
}

class _BleTestPageState extends State<BleTestPage> {
  static const helmetName = 'NeoRider-Helmet';
  static const String _rideId = '06';
  static const int _requiredReadings = 20;
  static const String neoRiderServiceUuid =
      '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String helmetCharacteristicUuid =
      '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String chestCharacteristicUuid =
      '6e400004-b5a3-f393-e0a9-e50e24dcca9e';

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _helmetSubscription;
  StreamSubscription<List<int>>? _chestSubscription;
  BluetoothDevice? _helmet;
  BluetoothAdapterState _adapterState = FlutterBluePlus.adapterStateNow;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  int _gattServiceCount = 0;
  bool _scanning = false;
  bool _busy = false;
  String _message = 'Ready to scan';
  NeoRiderSensorPacket? _latestHelmetPacket;
  NeoRiderSensorPacket? _latestChestPacket;
  final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);
  static const int _maxQueueDepth = 4;
  static const int _maxPendingPackets = 32;
  final Map<int, NeoRiderSensorPacket> _pendingHelmet = {};
  final Map<int, NeoRiderSensorPacket> _pendingChest = {};
  final Queue<({NeoRiderSensorPacket helmet, NeoRiderSensorPacket chest})>
  _pairQueue = Queue();
  final Set<int> _queuedSequences = {};
  bool _forwardWorkerActive = false;
  Timer? _metricsTimer;
  int _helmetPacketsReceived = 0;
  int _chestPacketsReceived = 0;
  int _matchedPairsCreated = 0;
  int _matchedPairsQueued = 0;
  int _matchedPairsSent = 0;
  int _httpFailures = 0;
  int _pairsDropped = 0;
  int _helmetAtLastLog = 0;
  int _chestAtLastLog = 0;
  int _matchedAtLastLog = 0;
  int _queuedAtLastLog = 0;
  int _sentAtLastLog = 0;
  int _failuresAtLastLog = 0;
  int? _lastForwardedSequence;
  String _backendState = 'WAITING';
  String _backendMessage = 'Set the PC IPv4 address, then check Backend.';
  String _backendResponseStatus = 'WAITING';
  int _helmetBufferSize = 0;
  int _chestBufferSize = 0;
  int _pairedBufferSize = 0;
  int _backendRequiredReadings = _requiredReadings;
  String? _prediction;
  double? _confidence;
  String? _modelUsed;
  String? _finalState;
  int? _accidentStreak;
  bool? _impactGatePassed;
  bool? _isHelmetStationary;
  bool? _isChestStationary;
  bool? _bothStationary;
  double? _fusedConfidence;
  String? _fusedPrediction;
  bool _checkingBackend = false;

  @override
  void initState() {
    super.initState();
    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) setState(() => _adapterState = state);
    });
    _metricsTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _logThroughput(),
    );
  }

  Future<void> _scan() async {
    if (_busy || _scanning) return;
    setState(() {
      _scanning = true;
      _message = 'Scanning for $helmetName...';
      _gattServiceCount = 0;
      _helmet = null;
      _latestHelmetPacket = null;
      _latestChestPacket = null;
      _lastForwardedSequence = null;
      _pendingHelmet.clear();
      _pendingChest.clear();
      _pairQueue.clear();
      _queuedSequences.clear();
    });

    try {
      if (!await FlutterBluePlus.isSupported) {
        throw StateError('Bluetooth Low Energy is not supported');
      }
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        throw StateError('Turn Bluetooth on, then scan again');
      }

      await _scanSubscription?.cancel();
      final helmetFound = Completer<void>();
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
        for (final result in results) {
          final name = result.advertisementData.advName.isNotEmpty
              ? result.advertisementData.advName
              : result.device.platformName;
          debugPrint(
            'BLE FOUND -> Name: "$name"  ID: ${result.device.remoteId}',
          );
          final isNeoRider = name == helmetName;
          if (isNeoRider && _helmet == null) {
            debugPrint('');
            debugPrint('=======================================');
            debugPrint('NEORIDER HELMET FOUND!');
            debugPrint('ID: ${result.device.remoteId}');
            debugPrint('=======================================');
            debugPrint('');

            _helmet = result.device;
            await FlutterBluePlus.stopScan();

            if (!mounted) return;
            setState(() {
              _scanning = false;
              _message = 'NeoRider Helmet found. Ready to connect.';
            });
            if (!helmetFound.isCompleted) helmetFound.complete();
            break;
          }
        }
      });

      // Intentionally no name/service filter while proving discovery works.
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: false,
      );
      await helmetFound.future.timeout(const Duration(seconds: 16));
    } on TimeoutException {
      if (mounted) setState(() => _message = '$helmetName was not found');
    } catch (error) {
      _showError(error);
    } finally {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      if (mounted) {
        setState(() {
          _scanning = false;
          if (_helmet == null && !_message.startsWith('Error:')) {
            _message = '$helmetName was not found';
          }
        });
      }
    }
  }

  Future<void> _connect() async {
    final device = _helmet;
    if (device == null || _busy) return;
    setState(() {
      _busy = true;
      _connectionState = BluetoothConnectionState.disconnected;
      _message = 'Connecting...';
      _gattServiceCount = 0;
      _latestHelmetPacket = null;
      _latestChestPacket = null;
    });

    try {
      await FlutterBluePlus.stopScan();
      await _cancelDataSubscriptions();
      if (mounted) setState(() => _scanning = false);

      debugPrint('');
      debugPrint('==========================================');
      debugPrint('CONNECTING TO NEORIDER');
      debugPrint('==========================================');
      debugPrint('');
      await _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        if (mounted) setState(() => _connectionState = state);
      });
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 15),
      );
      debugPrint('BLE CONNECT SUCCESS');

      await device.connectionState
          .firstWhere((state) => state == BluetoothConnectionState.connected)
          .timeout(const Duration(seconds: 10));
      debugPrint('CONNECTION STATE: CONNECTED');

      await Future<void>.delayed(const Duration(seconds: 1));
      debugPrint('');
      debugPrint('STARTING GATT DISCOVERY');

      final services = await device.discoverServices();
      debugPrint('GATT DISCOVERY COMPLETE');
      debugPrint('SERVICE COUNT: ${services.length}');

      for (final BluetoothService service in services) {
        debugPrint('');
        debugPrint('SERVICE UUID: ${service.uuid}');
        for (final BluetoothCharacteristic characteristic
            in service.characteristics) {
          debugPrint('  CHARACTERISTIC UUID: ${characteristic.uuid}');
          debugPrint('    READ: ${characteristic.properties.read}');
          debugPrint('    WRITE: ${characteristic.properties.write}');
          debugPrint(
            '    WRITE WITHOUT RESPONSE: '
            '${characteristic.properties.writeWithoutResponse}',
          );
          debugPrint('    NOTIFY: ${characteristic.properties.notify}');
          debugPrint('    INDICATE: ${characteristic.properties.indicate}');
        }
      }

      BluetoothCharacteristic? helmetCharacteristic;
      BluetoothCharacteristic? chestCharacteristic;

      for (final service in services) {
        if (service.uuid.toString().toLowerCase() == neoRiderServiceUuid) {
          for (final characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString().toLowerCase();
            if (uuid == helmetCharacteristicUuid) {
              helmetCharacteristic = characteristic;
            }
            if (uuid == chestCharacteristicUuid) {
              chestCharacteristic = characteristic;
            }
          }
        }
      }

      if (helmetCharacteristic == null || chestCharacteristic == null) {
        debugPrint('NEORIDER DATA CHARACTERISTICS NOT FOUND');
        if (mounted) {
          setState(() {
            _connectionState = BluetoothConnectionState.connected;
            _gattServiceCount = services.length;
            _message =
                'Connected, but NeoRider data characteristics '
                'were not found.';
          });
        }
        return;
      }

      _helmetSubscription = helmetCharacteristic.onValueReceived.listen(
        _handleHelmetNotification,
      );
      await helmetCharacteristic.setNotifyValue(true);

      _chestSubscription = chestCharacteristic.onValueReceived.listen(
        _handleChestNotification,
      );
      await chestCharacteristic.setNotifyValue(true);

      debugPrint('');
      debugPrint('NEORIDER HELMET/CHEST NOTIFICATIONS ENABLED');

      if (mounted) {
        setState(() {
          _connectionState = BluetoothConnectionState.connected;
          _gattServiceCount = services.length;
          _message = services.isEmpty
              ? 'Connected, but ESP32 returned 0 GATT services.'
              : 'Connected successfully. '
                    '${services.length} GATT service(s) found.';
        });
      }
    } catch (error, stackTrace) {
      await _cancelDataSubscriptions();
      debugPrint('');
      debugPrint('=======================================');
      debugPrint('BLE/GATT ERROR');
      debugPrint('$error');
      debugPrint('$stackTrace');
      debugPrint('=======================================');

      if (!mounted) return;
      setState(() => _message = 'BLE/GATT error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    final device = _helmet;
    if (device == null || _busy) return;
    setState(() {
      _busy = true;
      _message = 'Disconnecting...';
    });
    try {
      await _cancelDataSubscriptions();
      await device.disconnect();
      if (mounted) {
        setState(() {
          _connectionState = BluetoothConnectionState.disconnected;
          _gattServiceCount = 0;
          _latestHelmetPacket = null;
          _latestChestPacket = null;
          _message = 'Disconnected. Press Connect to test reconnect.';
        });
      }
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object error) {
    debugPrint('BLE ERROR: $error');
    if (mounted) setState(() => _message = 'Error: $error');
  }

  NeoRiderSensorPacket _decodeSensorPacket(List<int> data) {
    if (data.length != 20) {
      throw FormatException(
        'Invalid NeoRider packet length: ${data.length}; expected 20',
      );
    }
    final bytes = ByteData.sublistView(Uint8List.fromList(data));
    return NeoRiderSensorPacket(
      ax: bytes.getInt16(0, Endian.little) / 100.0,
      ay: bytes.getInt16(2, Endian.little) / 100.0,
      az: bytes.getInt16(4, Endian.little) / 100.0,
      gx: bytes.getInt16(6, Endian.little) / 10.0,
      gy: bytes.getInt16(8, Endian.little) / 10.0,
      gz: bytes.getInt16(10, Endian.little) / 10.0,
      pitch: bytes.getInt16(12, Endian.little) / 100.0,
      roll: bytes.getInt16(14, Endian.little) / 100.0,
      yaw: bytes.getInt16(16, Endian.little) / 100.0,
      sequence: bytes.getUint16(18, Endian.little),
    );
  }

  void _handleHelmetNotification(List<int> data) {
    try {
      final packet = _decodeSensorPacket(data);
      _helmetPacketsReceived++;
      if (mounted) setState(() => _latestHelmetPacket = packet);
      _pendingHelmet[packet.sequence] = packet;
      _createPairIfReady(packet.sequence);
      _trimPending(_pendingHelmet);
    } on FormatException catch (error) {
      debugPrint('HELMET PACKET REJECTED -> $error; RAW: $data');
    }
  }

  void _handleChestNotification(List<int> data) {
    try {
      final packet = _decodeSensorPacket(data);
      _chestPacketsReceived++;
      if (mounted) setState(() => _latestChestPacket = packet);
      _pendingChest[packet.sequence] = packet;
      _createPairIfReady(packet.sequence);
      _trimPending(_pendingChest);
    } on FormatException catch (error) {
      debugPrint('CHEST PACKET REJECTED -> $error; RAW: $data');
    }
  }

  void _createPairIfReady(int sequence) {
    final helmet = _pendingHelmet[sequence];
    final chest = _pendingChest[sequence];
    if (helmet == null || chest == null) return;
    _pendingHelmet.remove(sequence);
    _pendingChest.remove(sequence);
    _matchedPairsCreated++;
    if (_queuedSequences.contains(sequence)) return;
    if (_pairQueue.length >= _maxQueueDepth) {
      final dropped = _pairQueue.removeFirst();
      _queuedSequences.remove(dropped.helmet.sequence);
      _pairsDropped++;
    }
    _pairQueue.addLast((helmet: helmet, chest: chest));
    _queuedSequences.add(sequence);
    _matchedPairsQueued++;
    if (!_forwardWorkerActive) unawaited(_drainPairQueue());
  }

  void _trimPending(Map<int, NeoRiderSensorPacket> pending) {
    while (pending.length > _maxPendingPackets) {
      pending.remove(pending.keys.first);
    }
  }

  Future<void> _drainPairQueue() async {
    if (_forwardWorkerActive) return;
    _forwardWorkerActive = true;
    try {
      while (_pairQueue.isNotEmpty && mounted) {
        final pair = _pairQueue.removeFirst();
        _queuedSequences.remove(pair.helmet.sequence);
        try {
          final results = await Future.wait([
            _postSensorReading('helmet', pair.helmet),
            _postSensorReading('chest', pair.chest),
          ]);
          final result = results.reduce((best, candidate) {
            final bestSize =
                _jsonInt(best, 'helmet_buffer_size') +
                _jsonInt(best, 'chest_buffer_size');
            final candidateSize =
                _jsonInt(candidate, 'helmet_buffer_size') +
                _jsonInt(candidate, 'chest_buffer_size');
            final bestStatus = best['status']?.toString().toLowerCase();
            final candidateStatus = candidate['status']
                ?.toString()
                .toLowerCase();
            final bestRank =
                (bestStatus == 'collecting' ? 0 : 2000) +
                (best['final_state'] == null ? 0 : 1000) +
                bestSize;
            final candidateRank =
                (candidateStatus == 'collecting' ? 0 : 2000) +
                (candidate['final_state'] == null ? 0 : 1000) +
                candidateSize;
            return candidateRank > bestRank ? candidate : best;
          });
          _matchedPairsSent++;
          _applyBackendResult(result, pair.helmet.sequence);
        } catch (error) {
          _httpFailures++;
          _setBackendError('Backend failure: $error');
        }
      }
    } finally {
      _forwardWorkerActive = false;
      if (_pairQueue.isNotEmpty && mounted) unawaited(_drainPairQueue());
    }
  }

  void _logThroughput() {
    final helmetRate = _helmetPacketsReceived - _helmetAtLastLog;
    final chestRate = _chestPacketsReceived - _chestAtLastLog;
    final matchedRate = _matchedPairsCreated - _matchedAtLastLog;
    final queuedRate = _matchedPairsQueued - _queuedAtLastLog;
    final sentRate = _matchedPairsSent - _sentAtLastLog;
    final failureRate = _httpFailures - _failuresAtLastLog;
    _helmetAtLastLog = _helmetPacketsReceived;
    _chestAtLastLog = _chestPacketsReceived;
    _matchedAtLastLog = _matchedPairsCreated;
    _queuedAtLastLog = _matchedPairsQueued;
    _sentAtLastLog = _matchedPairsSent;
    _failuresAtLastLog = _httpFailures;
    debugPrint(
      '[THROUGHPUT][1s] helmet=$helmetRate chest=$chestRate '
      'matched=$matchedRate queued=$queuedRate sent=$sentRate '
      'httpFailures=$failureRate queueDepth=${_pairQueue.length} '
      'dropped=$_pairsDropped lastSent=${_lastForwardedSequence ?? '--'}',
    );
  }

  Future<Map<String, dynamic>> _postSensorReading(
    String device,
    NeoRiderSensorPacket packet,
  ) async {
    final request = await _httpClient.postUrl(_backendUri('/sensor/live'));
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'ride_id': _rideId,
        'device': device,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'accel_x': packet.ax,
        'accel_y': packet.ay,
        'accel_z': packet.az,
        'gyro_x': packet.gx,
        'gyro_y': packet.gy,
        'gyro_z': packet.gz,
        'mag_x': 0.0,
        'mag_y': 0.0,
        'mag_z': 0.0,
        'pitch': packet.pitch,
        'roll': packet.roll,
        'yaw': packet.yaw,
      }),
    );
    final response = await request.close().timeout(const Duration(seconds: 60));
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Status ${response.statusCode}: $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    return decoded;
  }

  Uri _backendUri(String path) => NeoRiderApiConfig.uri(path);

  void _applyBackendResult(Map<String, dynamic> result, int sequence) {
    final predictionData = result['prediction'];
    final responseStatus = result['status']?.toString() ?? 'unknown';
    final collecting = responseStatus.toLowerCase() == 'collecting';
    final rawFinalState = result['final_state']?.toString().trim();
    final normalizedFinalState = _normalizeFinalState(rawFinalState);
    final vibration = normalizedFinalState == 'ACCIDENT_CONFIRMED';
    final buzzer = normalizedFinalState == 'ACCIDENT_CONFIRMED';
    debugPrint('[FRONTEND][RAW_RESPONSE] ${jsonEncode(result)}');
    if (mounted) {
      setState(() {
        _backendState = 'CONNECTED';
        _backendMessage = responseStatus;
        _backendResponseStatus = responseStatus.toUpperCase();
        _helmetBufferSize = _jsonInt(result, 'helmet_buffer_size');
        _chestBufferSize = _jsonInt(result, 'chest_buffer_size');
        _pairedBufferSize = _jsonInt(result, 'buffer_size');
        _backendRequiredReadings = _jsonInt(
          result,
          'required_readings',
          fallback: _requiredReadings,
        );
        _lastForwardedSequence = sequence;
        _accidentStreak = (result['accident_streak'] as num?)?.toInt();
        _impactGatePassed = result['impact_gate_passed'] as bool?;
        _isHelmetStationary = result['is_helmet_stationary'] as bool?;
        _isChestStationary = result['is_chest_stationary'] as bool?;
        _bothStationary = result['both_stationary'] as bool?;
        if (!collecting) {
          _finalState = normalizedFinalState;
          _fusedConfidence = (result['fused_confidence'] as num?)?.toDouble();
          _fusedPrediction = result['fused_prediction']?.toString();
        }
        if (!collecting && predictionData is Map) {
          final prediction = Map<String, dynamic>.from(predictionData);
          _prediction = prediction['prediction']?.toString();
          _confidence = (prediction['confidence'] as num?)?.toDouble();
          _modelUsed = prediction['model_used']?.toString();
        }
      });
    }
    debugPrint(
      '[FRONTEND][BACKEND]\n'
      'status=${responseStatus.toLowerCase()}\n'
      'final_state=${collecting ? _finalState ?? 'UNKNOWN' : normalizedFinalState}\n'
      'prediction=${collecting ? _prediction : _prediction ?? predictionData}\n'
      'confidence=$_confidence\n'
      'impact_gate=${_impactGatePassed ?? 'UNKNOWN'}\n'
      'accident_streak=${_accidentStreak ?? 0}',
    );
    if (collecting) {
      debugPrint(
        '[FRONTEND][COLLECTING] No new inference; actuator state unchanged',
      );
    } else {
      debugPrint(
        '[FRONTEND][FEEDBACK] final_state=$normalizedFinalState '
        'vibration=$vibration buzzer=$buzzer',
      );
    }
  }

  String _normalizeFinalState(String? value) {
    final normalized = value?.toUpperCase();
    return switch (normalized) {
      'SAFE' ||
      'RISK' ||
      'ACCIDENT_PENDING' ||
      'ACCIDENT_CONFIRMED' ||
      'UNKNOWN' => normalized!,
      _ => 'UNKNOWN',
    };
  }

  int _jsonInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
    return (json[key] as num?)?.toInt() ?? fallback;
  }

  void _setBackendError(String message) {
    debugPrint('BACKEND ERROR -> $message');
    if (!mounted) return;
    setState(() {
      _backendState = 'ERROR';
      _backendMessage = message;
    });
  }

  Future<void> _checkBackend() async {
    if (_checkingBackend) return;
    setState(() {
      _checkingBackend = true;
      _backendState = 'WAITING';
      _backendMessage = 'Checking backend...';
    });
    try {
      final request = await _httpClient.getUrl(_backendUri('/'));
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Status ${response.statusCode}: $body');
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      if (mounted) {
        setState(() {
          _backendState = 'CONNECTED';
          _backendMessage = 'Backend reachable';
        });
      }
    } on TimeoutException catch (error) {
      _setBackendError('Health check timeout: $error');
    } on SocketException catch (error) {
      _setBackendError('Backend unreachable: ${error.message}');
    } catch (error) {
      _setBackendError('Backend health error: $error');
    } finally {
      if (mounted) setState(() => _checkingBackend = false);
    }
  }

  Future<void> _cancelDataSubscriptions() async {
    await _helmetSubscription?.cancel();
    await _chestSubscription?.cancel();
    _helmetSubscription = null;
    _chestSubscription = null;
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _connectionSubscription?.cancel();
    _helmetSubscription?.cancel();
    _chestSubscription?.cancel();
    _metricsTimer?.cancel();
    _pairQueue.clear();
    _queuedSequences.clear();
    FlutterBluePlus.stopScan();
    _httpClient.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final found = _helmet != null;
    final connected = _connectionState == BluetoothConnectionState.connected;
    return Scaffold(
      backgroundColor: const Color(0xFF07141D),
      appBar: AppBar(title: const Text('NeoRider BLE Foundation Test')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatusTile(
            title: 'Bluetooth Adapter',
            value: _adapterState.name.toUpperCase(),
            good: _adapterState == BluetoothAdapterState.on,
          ),
          _StatusTile(
            title: 'Helmet',
            value: found ? helmetName : 'NOT FOUND',
            good: found,
          ),
          _StatusTile(
            title: 'BLE Connection',
            value: _connectionState.name.toUpperCase(),
            good: connected,
          ),
          _StatusTile(
            title: 'GATT Services',
            value: _gattServiceCount == 0
                ? 'NOT FOUND'
                : '$_gattServiceCount FOUND',
            good: _gattServiceCount > 0,
          ),
          const SizedBox(height: 8),
          _SensorStreamCard(
            title: 'Helmet Stream',
            packet: _latestHelmetPacket,
          ),
          const SizedBox(height: 12),
          _SensorStreamCard(title: 'Chest Stream', packet: _latestChestPacket),
          const SizedBox(height: 12),
          _BackendCard(
            state: _backendState,
            message: _backendMessage,
            responseStatus: _backendResponseStatus,
            rideId: _rideId,
            helmetBufferSize: _helmetBufferSize,
            chestBufferSize: _chestBufferSize,
            pairedBufferSize: _pairedBufferSize,
            requiredReadings: _backendRequiredReadings,
            lastSentSequence: _lastForwardedSequence,
            prediction: _prediction,
            confidence: _confidence,
            modelUsed: _modelUsed,
            finalState: _finalState,
            accidentStreak: _accidentStreak,
            impactGatePassed: _impactGatePassed,
            isHelmetStationary: _isHelmetStationary,
            isChestStationary: _isChestStationary,
            bothStationary: _bothStationary,
            fusedConfidence: _fusedConfidence,
            fusedPrediction: _fusedPrediction,
            checking: _checkingBackend,
            onCheck: _checkBackend,
          ),
          const SizedBox(height: 12),
          Text(_message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _scanning || _busy ? null : _scan,
            icon: const Icon(Icons.bluetooth_searching),
            label: Text(_scanning ? 'Scanning...' : 'Scan for Helmet'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: found && !connected && !_busy ? _connect : null,
            icon: const Icon(Icons.bluetooth_connected),
            label: const Text('Connect'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: connected && !_busy ? _disconnect : null,
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _BackendCard extends StatelessWidget {
  const _BackendCard({
    required this.state,
    required this.message,
    required this.responseStatus,
    required this.rideId,
    required this.helmetBufferSize,
    required this.chestBufferSize,
    required this.pairedBufferSize,
    required this.requiredReadings,
    required this.lastSentSequence,
    required this.prediction,
    required this.confidence,
    required this.modelUsed,
    required this.finalState,
    required this.accidentStreak,
    required this.impactGatePassed,
    required this.isHelmetStationary,
    required this.isChestStationary,
    required this.bothStationary,
    required this.fusedConfidence,
    required this.fusedPrediction,
    required this.checking,
    required this.onCheck,
  });

  final String state;
  final String message;
  final String responseStatus;
  final String rideId;
  final int helmetBufferSize;
  final int chestBufferSize;
  final int pairedBufferSize;
  final int requiredReadings;
  final int? lastSentSequence;
  final String? prediction;
  final double? confidence;
  final String? modelUsed;
  final String? finalState;
  final int? accidentStreak;
  final bool? impactGatePassed;
  final bool? isHelmetStationary;
  final bool? isChestStationary;
  final bool? bothStationary;
  final double? fusedConfidence;
  final String? fusedPrediction;
  final bool checking;
  final VoidCallback onCheck;

  String get safetyLabel => switch (finalState) {
    'SAFE' => 'SAFE',
    'RISK' => 'RISK',
    'ACCIDENT_PENDING' => 'ACCIDENT PENDING',
    'ACCIDENT_CONFIRMED' => 'ACCIDENT',
    _ => 'UNKNOWN',
  };

  Color get safetyColor => switch (finalState) {
    'SAFE' => Colors.greenAccent,
    'RISK' || 'ACCIDENT_PENDING' => Colors.orangeAccent,
    'ACCIDENT_CONFIRMED' => Colors.redAccent,
    _ => Colors.white54,
  };

  @override
  Widget build(BuildContext context) {
    final connected = state == 'CONNECTED';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10232E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: connected
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : state == 'ERROR'
              ? Colors.redAccent.withValues(alpha: 0.45)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Backend',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                state,
                style: TextStyle(
                  color: connected
                      ? Colors.greenAccent
                      : state == 'ERROR'
                      ? Colors.redAccent
                      : Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text('Ride ID: $rideId'),
          Text('Helmet Buffer: $helmetBufferSize / $requiredReadings'),
          Text('Chest Buffer: $chestBufferSize / $requiredReadings'),
          Text('Paired Buffer: $pairedBufferSize / $requiredReadings'),
          Text('Last Sent Sequence: ${lastSentSequence ?? '--'}'),
          Text('Backend Status: $responseStatus'),
          const SizedBox(height: 10),
          const Text('Safety State', style: TextStyle(color: Colors.white54)),
          Text(
            safetyLabel,
            style: TextStyle(
              color: safetyColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Both Stationary: ${bothStationary == null
                ? 'UNKNOWN'
                : bothStationary!
                ? 'YES'
                : 'NO'}',
          ),
          Text('Accident Streak: ${accidentStreak ?? 0} / 3'),
          Text(
            'Impact Gate: ${impactGatePassed == null
                ? 'UNKNOWN'
                : impactGatePassed!
                ? 'PASS'
                : 'FAIL'}',
          ),
          Text(
            '${responseStatus == 'COLLECTING' ? 'Last Raw ML Prediction' : 'Raw ML Prediction'}: ${fusedPrediction ?? 'Waiting for prediction'}',
          ),
          Text(
            '${responseStatus == 'COLLECTING' ? 'Last Raw ML Confidence' : 'Raw ML Confidence'}: ${fusedConfidence ?? '--'}',
          ),
          const SizedBox(height: 10),
          if (prediction != null)
            Text('Nested Prediction (diagnostic): $prediction'),
          if (confidence != null) Text('Nested Confidence: $confidence'),
          if (modelUsed != null) Text('Model: $modelUsed'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: checking ? null : onCheck,
            icon: const Icon(Icons.health_and_safety_outlined),
            label: Text(checking ? 'Checking...' : 'Check Backend'),
          ),
        ],
      ),
    );
  }
}

class _SensorStreamCard extends StatelessWidget {
  const _SensorStreamCard({required this.title, required this.packet});

  final String title;
  final NeoRiderSensorPacket? packet;

  @override
  Widget build(BuildContext context) {
    final value = packet;
    final live = value != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10232E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: live
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                live ? 'LIVE' : 'WAITING',
                style: TextStyle(
                  color: live ? Colors.greenAccent : Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Sequence: ${value?.sequence ?? '--'}'),
          const SizedBox(height: 8),
          _SensorValueRow(
            label: 'Accel',
            x: value?.ax,
            y: value?.ay,
            z: value?.az,
          ),
          _SensorValueRow(
            label: 'Gyro',
            x: value?.gx,
            y: value?.gy,
            z: value?.gz,
          ),
          _SensorValueRow(
            label: 'Orientation',
            x: value?.pitch,
            y: value?.roll,
            z: value?.yaw,
            axisLabels: const ['Pitch', 'Roll', 'Yaw'],
          ),
        ],
      ),
    );
  }
}

class _SensorValueRow extends StatelessWidget {
  const _SensorValueRow({
    required this.label,
    required this.x,
    required this.y,
    required this.z,
    this.axisLabels = const ['X', 'Y', 'Z'],
  });

  final String label;
  final double? x;
  final double? y;
  final double? z;
  final List<String> axisLabels;

  String _format(double? value) => value?.toStringAsFixed(2) ?? '--';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 3),
          Text(
            '${axisLabels[0]} ${_format(x)}   '
            '${axisLabels[1]} ${_format(y)}   '
            '${axisLabels[2]} ${_format(z)}',
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.title,
    required this.value,
    required this.good,
  });

  final String title;
  final String value;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10232E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: good
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: good ? Colors.greenAccent : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
