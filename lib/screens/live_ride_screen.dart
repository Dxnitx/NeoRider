import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';

class LiveRideScreen extends StatelessWidget {
  const LiveRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: const [
                  Icon(Icons.motorcycle, size: 38),
                  SizedBox(width: 8),
                  Text("Speed", style: TextStyle(color: Color(0xFF408E1E), fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  Text("78 km/h", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text("Ride Time", style: TextStyle(color: Color(0xFF408E1E), fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Text("00:14:32", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Container(
              height: 70,
              color: const Color(0xFFF24822),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Text(
                    "Speed Limit Exceeded - Slow Down!",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFEAF2F8),
                child: const Center(
                  child: Text(
                    "Map / Route Twin Area",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Row(
                children: const [
                  Expanded(child: CameraBox(title: "Cam A  - Front")),
                  Expanded(child: CameraBox(title: "Cam B  - Back")),
                ],
              ),
            ),

            Container(
              height: 80,
              color: const Color(0xFF408E1E),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.turn_right, color: Colors.white, size: 42),
                  SizedBox(width: 18),
                  Text(
                    "Turn right in 100m",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: NeoRiderBottomNav(
          activeTab: NeoRiderNavTab.liveRide,
        ),
      ),
    );
  }
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
