import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';
import '../utils/responsive.dart';
import 'hard_braking_alert_screen.dart';
import 'helmet_strap_alert_screen.dart';
import 'high_speed_alert_screen.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  static const Color green = Color(0xFF39D353);
  static const Color dark = Color(0xFF02111D);

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Scaffold(
      backgroundColor: dark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _topHeader(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F8F7),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: responsive.pagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Alerts",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D1522),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Stay informed. Ride safer.",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 26),

                          Row(
                            children: [
                              _summaryBox(
                                Icons.shield,
                                "3",
                                "Critical",
                                Colors.red,
                              ),
                              const SizedBox(width: 12),
                              _summaryBox(
                                Icons.warning_rounded,
                                "2",
                                "Warnings",
                                Colors.orange,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              _summaryBox(Icons.info, "5", "Info", Colors.blue),
                              const SizedBox(width: 12),
                              _summaryBox(
                                Icons.check_circle,
                                "12",
                                "All Clear",
                                green,
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Recent Alerts",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0D1522),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Mark all as read",
                                    style: TextStyle(
                                      color: green,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: green,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          _alertCard(
                            icon: Icons.shield,
                            iconColor: Colors.red,
                            bgColor: const Color(0xFFFFE3E5),
                            title: "Hard Braking Detected",
                            desc:
                                "Hard braking detected at 8:45 AM.\nPlease ride carefully.",
                            time: "May 8, 2026  •  8:45 AM",
                            status: "Critical",
                            statusColor: Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HardBrakingAlertScreen(),
                                ),
                              );
                            },
                          ),

                          _alertCard(
                            icon: Icons.warning_rounded,
                            iconColor: Colors.orange,
                            bgColor: const Color(0xFFFFF1D8),
                            title: "High Speed Alert",
                            desc:
                                "You exceeded 80 km/h at 8:20 AM.\nStay within safe speed limits.",
                            time: "May 8, 2026  •  8:20 AM",
                            status: "Warning",
                            statusColor: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HighSpeedAlertScreen(),
                                ),
                              );
                            },
                          ),

                          _alertCard(
                            icon: Icons.notifications,
                            iconColor: Colors.blue,
                            bgColor: const Color(0xFFE2F0FF),
                            title: "Helmet Strap Reminder",
                            desc:
                                "Please fasten your helmet strap\nfor your safety.",
                            time: "May 8, 2026  •  8:10 AM",
                            status: "Info",
                            statusColor: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HelmetStrapAlertScreen(),
                                ),
                              );
                            },
                          ),

                          _alertCard(
                            icon: Icons.warning_rounded,
                            iconColor: Colors.orange,
                            bgColor: const Color(0xFFFFF1D8),
                            title: "Sharp Turn Detected",
                            desc:
                                "Sharp turn detected at 7:58 AM.\nMaintain control.",
                            time: "May 8, 2026  •  7:58 AM",
                            status: "Warning",
                            statusColor: Colors.orange,
                          ),

                          _alertCard(
                            icon: Icons.check,
                            iconColor: green,
                            bgColor: const Color(0xFFE2F8E8),
                            title: "Ride Completed",
                            desc:
                                "Great job! Your ride has been\ncompleted successfully.",
                            time: "May 8, 2026  •  7:30 AM",
                            status: "All Clear",
                            statusColor: green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: const NeoRiderBottomNav(activeTab: NeoRiderNavTab.alerts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white, size: 36),
          const SizedBox(width: 18),
          const Icon(Icons.sports_motorsports, color: green, size: 42),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "NeoRider",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                "Ride Smart, Ride Safe",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 36,
              ),
              Positioned(
                right: -2,
                top: -8,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "3",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(IconData icon, String count, String label, Color color) {
    return Expanded(
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 42),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String desc,
    required String time,
    required String status,
    required Color statusColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 36),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D1522),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          status,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black45,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
