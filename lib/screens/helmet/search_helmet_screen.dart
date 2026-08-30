import 'package:flutter/material.dart';
import '../../services/ble_service.dart';
import '../../services/ride_session.dart';
import '../../widgets/neorider_card.dart';
import '../../widgets/neorider_header.dart';
import '../../widgets/setup_progress.dart';
import 'place_chest_imu_screen.dart';

class SearchHelmetScreen extends StatefulWidget {
  const SearchHelmetScreen({super.key});
  @override
  State<SearchHelmetScreen> createState() => _SearchHelmetScreenState();
}

class _SearchHelmetScreenState extends State<SearchHelmetScreen> {
  final session = RideSession.instance;
  @override
  void initState() {
    super.initState();
    session.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => session.ble.scanForDevice(),
    );
  }

  @override
  void dispose() {
    session.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _connect() async {
    await session.ble.connect();
    if (mounted && session.bleConnected) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlaceChestImuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final found = session.ble.hasDiscoveredDevice;
    final busy =
        session.ble.state == NeoRiderBleState.scanning ||
        session.ble.state == NeoRiderBleState.connecting;
    return Scaffold(
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
                      'Search Smart Helmet',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Find and connect your NeoRider helmet',
                      style: TextStyle(color: Color(0xFF657184), fontSize: 17),
                    ),
                    const SizedBox(height: 28),
                    const SetupProgress(active: 1),
                    const SizedBox(height: 28),
                    NeoRiderCard(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 170,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                for (final size in [150.0, 110.0, 74.0])
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0x3329B84A),
                                      ),
                                    ),
                                  ),
                                const Icon(
                                  Icons.sports_motorsports,
                                  size: 76,
                                  color: Color(0xFF041522),
                                ),
                                const Positioned(
                                  right: 70,
                                  bottom: 18,
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Color(0xFF29B84A),
                                    child: Icon(
                                      Icons.bluetooth,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            found
                                ? 'NeoRider-Helmet found'
                                : busy
                                ? 'Searching nearby devices...'
                                : session.ble.status,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Turn on your helmet and keep it close to your phone.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF657184)),
                          ),
                        ],
                      ),
                    ),
                    if (found) ...[
                      const SizedBox(height: 18),
                      const NeoRiderCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: Color(0xFFEAF8EE),
                              child: Icon(
                                Icons.sports_motorsports,
                                color: Color(0xFF29B84A),
                                size: 36,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NeoRider-Helmet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Found • Smart helmet detected',
                                    style: TextStyle(color: Color(0xFF29B84A)),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.signal_cellular_alt,
                              color: Color(0xFF29B84A),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: found && !busy ? _connect : null,
                        icon: const Icon(Icons.bluetooth),
                        label: Text(busy ? 'Please wait...' : 'Connect Helmet'),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: busy ? null : session.ble.scanForDevice,
                        child: const Text('Scan Again'),
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
}
