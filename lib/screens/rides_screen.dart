import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';
import '../utils/responsive.dart';
import 'evening_ride_screen.dart';
import 'safe_riding_screen.dart';
import 'training_ride_screen.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  static const Color green = Color(0xFF39D353);
  static const Color dark = Color(0xFF02111D);

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: dark,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "My Rides",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: responsive.pagePadding,

        child: Column(
          children: [
            // SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: dark,
                borderRadius: BorderRadius.circular(26),
              ),

              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  SummaryItem("24", "Total Rides"),

                  SummaryItem("120 km", "Distance"),

                  SummaryItem("8h 45m", "Ride Time"),
                ],
              ),
            ),

            const SizedBox(height: 22),

            rideCard(
              title: "Morning Ride",
              date: "May 8, 2026",
              distance: "18 km",
              time: "45 min",
              score: "85%",
              status: "Safe Ride",
              color: green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SafeRidingScreen(),
                  ),
                );
              },
            ),

            rideCard(
              title: "Training Ride",
              date: "May 7, 2026",
              distance: "12 km",
              time: "32 min",
              score: "78%",
              status: "Good Ride",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainingRideScreen(),
                  ),
                );
              },
            ),

            rideCard(
              title: "Evening Ride",
              date: "May 6, 2026",
              distance: "21 km",
              time: "58 min",
              score: "64%",
              status: "Risk Alerts",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EveningRideScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: NeoRiderBottomNav(activeTab: NeoRiderNavTab.rides),
      ),
    );
  }

  Widget rideCard({
    required String title,
    required String date,
    required String distance,
    required String time,
    required String score,
    required String status,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
            ),
          ],
        ),

        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.15),

              child: Icon(Icons.sports_motorsports, color: color, size: 32),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "$date • $distance • $time",
                    style: const TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Safety Score: $score",
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}

class SummaryItem extends StatelessWidget {
  final String value;
  final String label;

  const SummaryItem(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
