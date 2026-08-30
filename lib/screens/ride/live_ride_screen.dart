import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/ride_session.dart';
import '../../widgets/neorider_card.dart';
import '../../widgets/neorider_header.dart';
import '../../widgets/status_pill.dart';
import 'accident_confirmed_screen.dart';
import 'accident_pending_screen.dart';
import 'risk_alert_screen.dart';

class LiveRideScreen extends StatefulWidget {
  const LiveRideScreen({super.key});
  @override
  State<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends State<LiveRideScreen> {
  final session = RideSession.instance;
  Timer? timer;
  String? _lastSafetyState;
  String? _pendingSafetyState;
  Route<void>? _activeSafetyRoute;
  bool _navigationInProgress = false;
  bool _navigationScheduled = false;
  @override
  void initState() {
    super.initState();
    session.addListener(_changed);
    session.startRide();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _lastSafetyState = session.finalState;
    _requestSafetyNavigation(session.finalState, initial: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    session.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    _requestSafetyNavigation(session.finalState);
  }

  void _requestSafetyNavigation(String state, {bool initial = false}) {
    if (!mounted) return;
    final previous = _lastSafetyState;
    if (!initial && state == previous) return;
    _lastSafetyState = state;
    _pendingSafetyState = state;
    debugPrint('[NAV] ${previous ?? 'INITIAL'} -> $state');
    if (_navigationInProgress || _navigationScheduled) {
      debugPrint('[NAV] navigation busy; queued latest transition to $state');
      return;
    }
    _scheduleSafetyNavigation();
  }

  void _scheduleSafetyNavigation() {
    if (_navigationScheduled || !mounted) return;
    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationScheduled = false;
      if (!mounted) return;
      _performSafetyNavigation();
    });
  }

  void _performSafetyNavigation() {
    if (!mounted || _navigationInProgress) return;
    final state = _pendingSafetyState;
    if (state == null) return;
    _pendingSafetyState = null;
    _navigationInProgress = true;

    final target = _screenForSafetyState(state);
    if (target == null) {
      final activeRoute = _activeSafetyRoute;
      if (activeRoute != null && activeRoute.isActive) {
        Navigator.of(context).pop();
      }
      _activeSafetyRoute = null;
    } else if (_activeSafetyRoute != null &&
        _activeSafetyRoute!.isActive) {
      final route = MaterialPageRoute<void>(builder: (_) => target);
      _activeSafetyRoute = route;
      Navigator.of(context).pushReplacement(route);
      _watchSafetyRoute(route, state);
    } else {
      final route = MaterialPageRoute<void>(builder: (_) => target);
      _activeSafetyRoute = route;
      Navigator.of(context).push(route);
      _watchSafetyRoute(route, state);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigationInProgress = false;
      if (_pendingSafetyState != null) _scheduleSafetyNavigation();
    });
  }

  void _watchSafetyRoute(Route<void> route, String state) {
    route.popped.then((_) {
      if (!mounted || !identical(_activeSafetyRoute, route)) return;
      _activeSafetyRoute = null;
      debugPrint('[NAV] $state screen closed');
    });
  }

  Widget? _screenForSafetyState(String state) => switch (state) {
    'RISK' => const RiskAlertScreen(),
    'ACCIDENT_PENDING' => const AccidentPendingScreen(),
    'ACCIDENT_CONFIRMED' => const AccidentConfirmedScreen(),
    _ => null,
  };

  String get elapsed {
    final d = DateTime.now().difference(
      session.rideStartedAt ?? DateTime.now(),
    );
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    body: SafeArea(
      child: Column(
        children: [
          const NeoRiderHeader(label: 'LIVE RIDE'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D7431), Color(0xFF29B84A)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.shield, color: Colors.white, size: 64),
                        SizedBox(height: 10),
                        Text(
                          'Safety Monitoring Active',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Keep your attention on the road',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeoRiderCard(
                    child: Column(
                      children: [
                        _row('Helmet Sensor', session.helmetSensorReceiving),
                        _row('Chest Sensor', session.chestSensorReceiving),
                        _row('Backend', session.backendOnline),
                      ],
                    ),
                  ),
                  if (!session.backendOnline &&
                      session.backendMessage != null) ...[
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.cloud_off, color: Color(0xFFFF8A00)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Backend temporarily unavailable. Safety output has been cleared while BLE monitoring continues.',
                            style: TextStyle(color: Color(0xFF657184)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _metric(
                          'Prediction',
                          session.finalState,
                          const Color(0xFF29B84A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metric(
                          'Confidence',
                          '${(session.confidence * (session.confidence <= 1 ? 100 : 1)).round()}%',
                          const Color(0xFF29B84A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metric(
                          'Ride Time',
                          elapsed,
                          const Color(0xFF101820),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const NeoRiderCard(
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF29B84A)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sensor packets remain synchronized and are sent to the safety backend throughout your ride.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _row(String name, bool active) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(name),
    trailing: StatusPill(text: active ? 'Active' : 'Offline', active: active),
  );
  Widget _metric(String label, String value, Color color) => NeoRiderCard(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
    child: Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF657184), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
