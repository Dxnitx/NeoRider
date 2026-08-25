import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';
import '../utils/responsive.dart';

class LiveRideScreen extends StatelessWidget {
  const LiveRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: responsive.sectionSpacing),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: 12,
                ),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  children: const [
                    _RideMetric(
                      icon: Icons.motorcycle,
                      label: 'Speed',
                      value: '78 km/h',
                    ),
                    _RideMetric(
                      icon: Icons.timer_outlined,
                      label: 'Ride Time',
                      value: '00:14:32',
                    ),
                  ],
                ),
              ),

              Container(
                constraints: const BoxConstraints(minHeight: 64),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: 12,
                ),
                color: const Color(0xFFF24822),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Speed Limit Exceeded - Slow Down!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: (responsive.height * 0.38).clamp(240.0, 420.0),
                width: double.infinity,
                color: const Color(0xFFEAF2F8),
                child: const Center(
                  child: Text(
                    "Map / Route Twin Area",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: (responsive.width * 0.4).clamp(130.0, 190.0),
                child: const Row(
                  children: [
                    Expanded(child: CameraBox(title: "Cam A  - Front")),
                    Expanded(child: CameraBox(title: "Cam B  - Back")),
                  ],
                ),
              ),

              Container(
                constraints: const BoxConstraints(minHeight: 68),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: 12,
                ),
                color: const Color(0xFF408E1E),
                child: const Row(
                  children: [
                    Icon(Icons.turn_right, color: Colors.white, size: 42),
                    SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        "Turn right in 100m",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: NeoRiderBottomNav(activeTab: NeoRiderNavTab.liveRide),
      ),
    );
  }
}

class _RideMetric extends StatelessWidget {
  const _RideMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 30),
      const SizedBox(width: 7),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF408E1E),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 7),
      Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class CameraBox extends StatelessWidget {
  final String title;

  const CameraBox({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black12,
          child: const Center(
            child: Icon(Icons.videocam, size: 45, color: Colors.black45),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(title, style: const TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
