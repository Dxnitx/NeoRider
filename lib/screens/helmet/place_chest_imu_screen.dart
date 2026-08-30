import 'package:flutter/material.dart';
import '../../services/ride_session.dart';
import '../../widgets/neorider_card.dart';
import '../../widgets/neorider_header.dart';
import '../../widgets/setup_progress.dart';
import '../../widgets/status_pill.dart';
import 'check_sensors_screen.dart';

class PlaceChestImuScreen extends StatefulWidget {
  const PlaceChestImuScreen({super.key});
  @override
  State<PlaceChestImuScreen> createState() => _PlaceChestImuScreenState();
}

class _PlaceChestImuScreenState extends State<PlaceChestImuScreen> {
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
          const NeoRiderHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Place Chest IMU',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      StatusPill(
                        text: session.bleConnected
                            ? 'Helmet Connected'
                            : 'Disconnected',
                        active: session.bleConnected,
                      ),
                    ],
                  ),
                  const Text(
                    'Attach the chest sensor before starting your ride',
                    style: TextStyle(color: Color(0xFF657184), fontSize: 16),
                  ),
                  const SizedBox(height: 26),
                  const SetupProgress(active: 2),
                  const SizedBox(height: 24),
                  NeoRiderCard(
                    child: SizedBox(
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.accessibility_new,
                            size: 250,
                            color: Colors.blueGrey.shade100,
                          ),
                          for (final size in [120.0, 80.0])
                            Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFF29B84A,
                                  ).withValues(alpha: .35),
                                ),
                              ),
                            ),
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFF041522),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x5529B84A),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sensors,
                              color: Color(0xFF29B84A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final item in const [
                    (
                      Icons.my_location,
                      'Place at center chest',
                      'Position the sensor around the center of your chest.',
                    ),
                    (
                      Icons.shield_outlined,
                      'Keep firmly attached',
                      'Ensure the sensor is secure and does not move unnecessarily.',
                    ),
                    (
                      Icons.sync,
                      'Keep placement consistent',
                      'Avoid loose placement that changes sensor orientation.',
                    ),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeoRiderCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFEAF8EE),
                              child: Icon(
                                item.$1,
                                color: const Color(0xFF29B84A),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    item.$3,
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
                    ),
                  NeoRiderCard(
                    child: Row(
                      children: [
                        Icon(
                          session.chestSensorReceiving
                              ? Icons.check_circle
                              : Icons.hourglass_top,
                          color: session.chestSensorReceiving
                              ? const Color(0xFF29B84A)
                              : const Color(0xFFFF8A00),
                          size: 35,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            session.chestSensorReceiving
                                ? 'Chest IMU detected\nReceiving live sensor data'
                                : 'Waiting for Chest IMU data...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: session.chestSensorReceiving
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckSensorsScreen(),
                              ),
                            )
                          : null,
                      child: const Text('Continue'),
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
