import 'package:flutter/material.dart';
import '../../services/ride_session.dart';
import '../../widgets/neorider_card.dart';
import '../../widgets/neorider_header.dart';
import '../../widgets/sensor_live_card.dart';
import '../../widgets/setup_progress.dart';
import '../ride/live_ride_screen.dart';

class CheckSensorsScreen extends StatefulWidget {
  const CheckSensorsScreen({super.key});
  @override
  State<CheckSensorsScreen> createState() => _CheckSensorsScreenState();
}

class _CheckSensorsScreenState extends State<CheckSensorsScreen> {
  final session = RideSession.instance;
  @override
  void initState() {
    super.initState();
    session.addListener(_refresh);
    session.checkBackend();
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
          const NeoRiderHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check Sensors',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    'Make sure both sensors are working correctly',
                    style: TextStyle(color: Color(0xFF657184), fontSize: 16),
                  ),
                  const SizedBox(height: 26),
                  const SetupProgress(active: 3),
                  const SizedBox(height: 24),
                  SensorLiveCard(
                    title: 'Helmet IMU',
                    reading: session.helmet,
                    live: session.helmetSensorReceiving,
                    icon: Icons.sports_motorsports,
                  ),
                  const SizedBox(height: 14),
                  SensorLiveCard(
                    title: 'Chest IMU',
                    reading: session.chest,
                    live: session.chestSensorReceiving,
                    icon: Icons.sensors,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'SYSTEM STATUS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  NeoRiderCard(
                    child: Column(
                      children: [
                        _status(
                          Icons.bluetooth,
                          'BLE Connected',
                          session.bleConnected,
                        ),
                        const Divider(),
                        _status(
                          Icons.cloud_outlined,
                          'Backend Online',
                          session.backendOnline,
                        ),
                        const Divider(),
                        _status(
                          Icons.monitor_heart_outlined,
                          'Packet Stream Stable',
                          session.packetStreamStable,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeoRiderCard(
                    child: Row(
                      children: [
                        Icon(
                          session.readyToRide
                              ? Icons.verified_user
                              : Icons.info_outline,
                          size: 50,
                          color: session.readyToRide
                              ? const Color(0xFF29B84A)
                              : const Color(0xFFFF8A00),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.readyToRide
                                    ? 'Both sensors are working'
                                    : 'Waiting for all systems',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                session.readyToRide
                                    ? 'Your helmet and chest IMU are ready for live monitoring.'
                                    : (session.backendMessage ??
                                          'Keep both sensors active.'),
                                style: const TextStyle(
                                  color: Color(0xFF657184),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: session.bleConnected
                          ? () async {
                              await RideSession.instance.testMotor();
                            }
                          : null,
                      icon: const Icon(Icons.vibration),
                      label: const Text('TEST MOTOR'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: session.readyToRide
                          ? () {
                              session.startRide();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LiveRideScreen(),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.bluetooth),
                      label: const Text('START LIVE RIDE'),
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
  Widget _status(IconData icon, String title, bool active) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      icon,
      color: active ? const Color(0xFF29B84A) : const Color(0xFF657184),
    ),
    title: Text(title),
    trailing: Icon(
      active ? Icons.check_circle : Icons.cancel_outlined,
      color: active ? const Color(0xFF29B84A) : Colors.grey,
    ),
  );
}
