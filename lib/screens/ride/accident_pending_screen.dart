import 'package:flutter/material.dart';
import '../../services/ride_session.dart';
import '../../widgets/accident_progress_card.dart';
import '../../widgets/neorider_card.dart';
import '../../widgets/neorider_header.dart';

class AccidentPendingScreen extends StatefulWidget {
  const AccidentPendingScreen({super.key});
  @override
  State<AccidentPendingScreen> createState() => _AccidentPendingScreenState();
}

class _AccidentPendingScreenState extends State<AccidentPendingScreen> {
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
  Widget build(BuildContext context) {
    final backend = session.backend;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            const NeoRiderHeader(label: 'CHECKING'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A00),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                          Text(
                            'POSSIBLE ACCIDENT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'NeoRider is checking sensor readings.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AccidentProgressCard(streak: backend?.accidentStreak ?? 0),
                    const SizedBox(height: 14),
                    NeoRiderCard(
                      child: Column(
                        children: [
                          _detail(
                            'Impact Gate',
                            backend?.impactGatePassed == true
                                ? 'Triggered'
                                : 'Monitoring',
                          ),
                          const Divider(),
                          _detail(
                            'Both Stationary',
                            backend?.bothStationary == true ? 'Yes' : 'No',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const NeoRiderCard(
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFFFF8A00)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Emergency calling has not started. Monitoring continues while the backend confirms the event.',
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
  }

  Widget _detail(String name, String value) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(name),
    trailing: Text(
      value,
      style: const TextStyle(
        color: Color(0xFFFF8A00),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
