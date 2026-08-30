import 'package:flutter/material.dart';
import '../../services/ride_session.dart';
import '../../widgets/neorider_card.dart';
import '../../widgets/neorider_header.dart';

class RiskAlertScreen extends StatefulWidget {
  const RiskAlertScreen({super.key});
  @override
  State<RiskAlertScreen> createState() => _RiskAlertScreenState();
}

class _RiskAlertScreenState extends State<RiskAlertScreen> {
  final session = RideSession.instance;

  @override
  void initState() {
    super.initState();
    session.addListener(_refresh);
  }

  @override
  void dispose() {
    session.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
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
                  _hero(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _metric(
                          Icons.analytics_outlined,
                          'Prediction',
                          'RISK',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metric(
                          Icons.donut_large,
                          'Confidence',
                          '${(session.confidence * (session.confidence <= 1 ? 100 : 1)).round()}%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _metric(
                          Icons.sports_motorsports,
                          'Helmet Sensor',
                          session.helmetSensorReceiving ? 'Active' : 'Offline',
                          green: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metric(
                          Icons.sensors,
                          'Chest Sensor',
                          session.chestSensorReceiving ? 'Active' : 'Offline',
                          green: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  NeoRiderCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Take control now',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _advice(
                          Icons.speed,
                          'Reduce speed',
                          'Slow down to regain control.',
                        ),
                        _advice(
                          Icons.airline_seat_recline_normal,
                          'Stabilize posture',
                          'Keep your body balanced.',
                        ),
                        _advice(
                          Icons.sports_motorsports,
                          'Keep both hands steady',
                          'Maintain a firm grip on the handlebar.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A00),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.monitor_heart),
                      label: const Text('Continue Monitoring'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.shield_outlined),
                      label: const Text("I'm Okay"),
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
  Widget _hero() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF5E2500), Color(0xFFFF8A00)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Column(
      children: [
        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 70),
        Text(
          'RISK DETECTED',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'Unstable riding behaviour detected\nStay focused. Ride safe.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
        ),
      ],
    ),
  );
  Widget _metric(
    IconData icon,
    String label,
    String value, {
    bool green = false,
  }) => NeoRiderCard(
    child: Column(
      children: [
        Icon(
          icon,
          color: green ? const Color(0xFF29B84A) : const Color(0xFFFF8A00),
          size: 34,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF657184)),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: green ? const Color(0xFF29B84A) : const Color(0xFFFF7900),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
  Widget _advice(IconData icon, String title, String body) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: const Color(0xFFFFF4E5),
      child: Icon(icon, color: const Color(0xFFFF8A00)),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(body),
  );
}
