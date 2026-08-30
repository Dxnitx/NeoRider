import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/ble_sensor_reading.dart';
import '../models/neorider_sensor_pair.dart';
import '../models/prediction_result.dart';

class NeoRiderApiService {
  NeoRiderApiService({this.rideId = '06'});

  static const String baseUrl = NeoRiderApiConfig.baseUrl;
  static const int defaultRequiredReadings = 20;

  final String rideId;
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);
  bool _disposed = false;
  int _nextLiveRequestId = 0;

  Future<bool> checkHealth() async {
    final request = await _client.getUrl(_uri('/'));
    final response = await request.close().timeout(const Duration(seconds: 10));
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Status ${response.statusCode}: $body');
    }
    return true;
  }

  Future<BackendResult> sendPair(NeoRiderSensorPair pair) async {
    if (_disposed) throw StateError('API service is disposed');
    final responses = await Future.wait([
      _postReading('helmet', pair.helmet),
      _postReading('chest', pair.chest),
    ]);
    final results = responses
        .map(
          (response) => _parseResult(
            response.json,
            requestId: response.requestId,
            device: response.device,
          ),
        )
        .toList(growable: false);
    return results.reduce((best, candidate) {
      final bestRank =
          (best.finalState == null ? 0 : 2000) +
          (best.prediction == null ? 0 : 1000) +
          best.helmetBufferSize +
          best.chestBufferSize;
      final candidateRank =
          (candidate.finalState == null ? 0 : 2000) +
          (candidate.prediction == null ? 0 : 1000) +
          candidate.helmetBufferSize +
          candidate.chestBufferSize;
      return candidateRank > bestRank ? candidate : best;
    });
  }

  Future<({int requestId, String device, Map<String, dynamic> json})>
  _postReading(String device, BleSensorReading reading) async {
    final requestId = ++_nextLiveRequestId;
    final request = await _client.postUrl(_uri('/sensor/live'));
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'ride_id': rideId,
        'device': device,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'accel_x': reading.accelX,
        'accel_y': reading.accelY,
        'accel_z': reading.accelZ,
        'gyro_x': reading.gyroX,
        'gyro_y': reading.gyroY,
        'gyro_z': reading.gyroZ,
        'mag_x': 0.0,
        'mag_y': 0.0,
        'mag_z': 0.0,
        'pitch': reading.pitch,
        'roll': reading.roll,
        'yaw': reading.yaw,
      }),
    );
    final response = await request.close().timeout(const Duration(seconds: 60));
    final body = await utf8.decoder.bind(response).join();
    debugPrint('[API][LIVE] status=${response.statusCode}');
    debugPrint('[API][LIVE] body=$body');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Status ${response.statusCode}: $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    return (requestId: requestId, device: device, json: decoded);
  }

  BackendResult _parseResult(
    Map<String, dynamic> json, {
    required int requestId,
    required String device,
  }) {
    final rawPrediction = json['prediction'];
    PredictionResult? prediction;
    if (rawPrediction is Map) {
      final data = Map<String, dynamic>.from(rawPrediction);
      final label = data['prediction']?.toString();
      if (label != null && label.isNotEmpty) {
        prediction = PredictionResult(
          label: label,
          confidence: (data['confidence'] as num?)?.toDouble(),
          modelUsed: data['model_used']?.toString(),
        );
      }
    } else if (rawPrediction is String && rawPrediction.isNotEmpty) {
      prediction = PredictionResult(
        label: rawPrediction,
        confidence: (json['confidence'] as num?)?.toDouble(),
        modelUsed: json['model_used']?.toString(),
      );
    }
    final result = BackendResult(
      status: json['status']?.toString() ?? 'collecting',
      rideId: json['ride_id']?.toString() ?? rideId,
      helmetBufferSize: _int(json, 'helmet_buffer_size'),
      chestBufferSize: _int(json, 'chest_buffer_size'),
      pairedBufferSize: _int(
        json,
        'paired_buffer_size',
        fallback: _int(json, 'buffer_size'),
      ),
      requiredReadings: _int(
        json,
        'required_readings',
        fallback: defaultRequiredReadings,
      ),
      finalState: _nonEmptyString(json['final_state']),
      accidentStreak: (json['accident_streak'] as num?)?.toInt(),
      impactGatePassed:
          json['impact_gate_passed'] as bool? ?? json['impact_gate'] as bool?,
      isHelmetStationary: json['is_helmet_stationary'] as bool?,
      isChestStationary: json['is_chest_stationary'] as bool?,
      bothStationary: json['both_stationary'] as bool?,
      fusedPrediction: _nonEmptyString(json['fused_prediction']),
      fusedConfidence: (json['fused_confidence'] as num?)?.toDouble(),
      prediction: prediction,
      requestId: requestId,
      device: device,
    );
    final safetyFields = <String>[
      'final_state=${result.finalState}',
      'fused_prediction=${result.fusedPrediction}',
      'fused_confidence=${result.fusedConfidence}',
      'status=${result.status}',
      if (json.containsKey('helmet_prediction'))
        'helmet_prediction=${json['helmet_prediction']}',
      if (json.containsKey('chest_prediction'))
        'chest_prediction=${json['chest_prediction']}',
      'accident_streak=${result.accidentStreak}',
      'impact_gate=${result.impactGatePassed}',
      'is_helmet_stationary=${result.isHelmetStationary}',
      'is_chest_stationary=${result.isChestStationary}',
      'both_stationary=${result.bothStationary}',
    ];
    debugPrint('[API][PARSED] ${safetyFields.join(' ')}');
    debugPrint(
      '[SAFETY][INPUT] request=$requestId device=$device '
      'status=${result.status} final_state=${result.finalState} '
      'fused_prediction=${result.fusedPrediction}',
    );
    return result;
  }

  int _int(Map<String, dynamic> json, String key, {int fallback = 0}) =>
      (json[key] as num?)?.toInt() ?? fallback;

  String? _nonEmptyString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  Uri _uri(String path) => NeoRiderApiConfig.uri(path);

  void dispose() {
    _disposed = true;
    _client.close(force: true);
  }
}

typedef PairSentCallback =
    void Function(NeoRiderSensorPair pair, BackendResult result);
typedef PairFailureCallback =
    void Function(NeoRiderSensorPair pair, Object error);

/// A single bounded FIFO of complete synchronized pairs.
/// BLE callbacks only enqueue; this worker owns all HTTP activity.
class NeoRiderPairForwarder {
  NeoRiderPairForwarder({
    required this.api,
    required this.onSent,
    required this.onFailure,
    this.maxQueueDepth = 4,
  }) : assert(maxQueueDepth > 0) {
    _metricsTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _logMetrics(),
    );
  }

  final NeoRiderApiService api;
  final PairSentCallback onSent;
  final PairFailureCallback onFailure;
  final int maxQueueDepth;
  final Queue<NeoRiderSensorPair> _queue = Queue<NeoRiderSensorPair>();
  final Set<int> _queuedSequences = <int>{};
  Timer? _metricsTimer;
  bool _working = false;
  bool _disposed = false;
  int? _inFlightSequence;
  int? lastSentSequence;
  int pairsQueued = 0;
  int pairsSent = 0;
  int httpFailures = 0;
  int pairsDropped = 0;
  int _queuedAtLastLog = 0;
  int _sentAtLastLog = 0;
  int _failuresAtLastLog = 0;

  int get queueDepth => _queue.length;

  void enqueue(NeoRiderSensorPair pair) {
    if (_disposed || pair.helmet.sequence != pair.chest.sequence) return;
    if (_inFlightSequence == pair.sequence ||
        _queuedSequences.contains(pair.sequence)) {
      return;
    }
    if (_queue.length >= maxQueueDepth) {
      final dropped = _queue.removeFirst();
      _queuedSequences.remove(dropped.sequence);
      pairsDropped++;
    }
    _queue.addLast(pair);
    _queuedSequences.add(pair.sequence);
    pairsQueued++;
    if (!_working) unawaited(_drain());
  }

  Future<void> _drain() async {
    if (_working || _disposed) return;
    _working = true;
    try {
      while (_queue.isNotEmpty && !_disposed) {
        final pair = _queue.removeFirst();
        _queuedSequences.remove(pair.sequence);
        _inFlightSequence = pair.sequence;
        try {
          final result = await api.sendPair(pair);
          pairsSent++;
          lastSentSequence = pair.sequence;
          onSent(pair, result);
        } catch (error) {
          httpFailures++;
          onFailure(pair, error);
        } finally {
          _inFlightSequence = null;
        }
      }
    } finally {
      _working = false;
      if (_queue.isNotEmpty && !_disposed) unawaited(_drain());
    }
  }

  void _logMetrics() {
    final queuedRate = pairsQueued - _queuedAtLastLog;
    final sentRate = pairsSent - _sentAtLastLog;
    final failureRate = httpFailures - _failuresAtLastLog;
    _queuedAtLastLog = pairsQueued;
    _sentAtLastLog = pairsSent;
    _failuresAtLastLog = httpFailures;
    debugPrint(
      '[FORWARD][1s] pairsQueued=$queuedRate pairsSent=$sentRate '
      'httpFailures=$failureRate queueDepth=$queueDepth dropped=$pairsDropped '
      'lastSentSequence=${lastSentSequence ?? '--'}',
    );
  }

  void dispose() {
    _disposed = true;
    _metricsTimer?.cancel();
    _metricsTimer = null;
    _queue.clear();
    _queuedSequences.clear();
  }
}
