import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';
import '../utils/responsive.dart';
import 'emergency_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color green = Color(0xFF39D353);
  static const Color dark = Color(0xFF02111D);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsive = NeoResponsive.of(context);
    final useVerticalHero = screenWidth < 500;
    final heroFontSize = (screenWidth * 0.095).clamp(30.0, 38.0);

    return Scaffold(
      backgroundColor: dark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // TOP HEADER
                Container(
                  height: 110,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu, color: Colors.white, size: 36),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.sports_motorsports,
                        color: green,
                        size: 42,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "NeoRider",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              "Ride Smart, Ride Safe",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 36,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 24,
                              height: 24,
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
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7F6),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: responsive.pagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HELLO SECTION
                          Flex(
                            direction: responsive.isSmallPhone
                                ? Axis.vertical
                                : Axis.horizontal,
                            crossAxisAlignment: responsive.isSmallPhone
                                ? CrossAxisAlignment.stretch
                                : CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: responsive.isSmallPhone
                                    ? double.infinity
                                    : screenWidth - 220,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hello, Rider! 👋",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Welcome back to NeoRider",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: responsive.isSmallPhone ? 0 : 10,
                                height: responsive.isSmallPhone ? 12 : 0,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: green,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.bluetooth,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Connected",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Smart Helmet",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // HERO CARD
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 420),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              image: const DecorationImage(
                                image: AssetImage("assets/images/biker_bg.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.88),
                                    Colors.black.withValues(alpha: 0.2),
                                  ],
                                ),
                              ),
                              child: Flex(
                                direction: useVerticalHero
                                    ? Axis.vertical
                                    : Axis.horizontal,
                                crossAxisAlignment: useVerticalHero
                                    ? CrossAxisAlignment.stretch
                                    : CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: useVerticalHero
                                        ? null
                                        : screenWidth -
                                              (responsive.horizontalPadding *
                                                  2) -
                                              48 -
                                              12 -
                                              145,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          "Ride Safe.",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: heroFontSize,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          "Train Smart.",
                                          style: TextStyle(
                                            color: green,
                                            fontSize: heroFontSize,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          "Real-time monitoring, AI insights\nand smart alerts for a safer\nevery ride.",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 28),
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/ride-setup',
                                          ),
                                          child: Container(
                                            width: 180,
                                            height: 58,
                                            decoration: BoxDecoration(
                                              color: green,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Start Ride",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: useVerticalHero ? 0 : 12,
                                    height: useVerticalHero ? 12 : 0,
                                  ),

                                  // RIGHT STATS
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      statBox(
                                        Icons.shield,
                                        "Safety Score",
                                        "85%",
                                        Colors.green,
                                      ),
                                      const SizedBox(height: 18),
                                      statBox(
                                        Icons.bar_chart,
                                        "Total Rides",
                                        "24",
                                        Colors.white,
                                      ),
                                      const SizedBox(height: 18),
                                      statBox(
                                        Icons.local_fire_department,
                                        "Streak",
                                        "7 Days",
                                        Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // QUICK ACTIONS
                          const Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/ride-setup',
                                  ),
                                  child: quickCard(
                                    Icons.sports_motorsports,
                                    "Start Ride",
                                    "Begin monitoring",
                                    green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: quickCard(
                                  Icons.school,
                                  "Training",
                                  "Improve your skills",
                                  Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: quickCard(
                                  Icons.map,
                                  "Route Twin",
                                  "Plan your route",
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EmergencyScreen(),
                                      ),
                                    );
                                  },
                                  child: quickCard(
                                    Icons.warning,
                                    "Emergency",
                                    "SOS & contacts",
                                    Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // RIDE OVERVIEW TITLE
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Ride Overview",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "View all",
                                    style: TextStyle(
                                      color: green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward, color: green),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // RIDE OVERVIEW CARD
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: CircularProgressIndicator(
                                              value: 0.85,
                                              strokeWidth: 10,
                                              color: green,
                                              backgroundColor: Color(
                                                0xFFDDF3E3,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "85%",
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Safety Score",
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Great job!",
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "Keep riding safe.",
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 28),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: statItem(
                                        Icons.route,
                                        "120 km",
                                        "Total Distance",
                                        green,
                                      ),
                                    ),
                                    Expanded(
                                      child: statItem(
                                        Icons.access_time,
                                        "8h 45m",
                                        "Total Time",
                                        Colors.blue,
                                      ),
                                    ),
                                    Expanded(
                                      child: statItem(
                                        Icons.calendar_month,
                                        "24",
                                        "Total Rides",
                                        Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // RECENT ACTIVITY
                          const Text(
                            "Recent Activity",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sports_motorsports,
                                  color: green,
                                  size: 40,
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Morning Ride",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "May 8, 2026 • 18 km • 45 min",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDDF3E3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Safe Ride",
                                    style: TextStyle(
                                      color: green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.arrow_forward, color: green),
                              ],
                            ),
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
              child: const NeoRiderBottomNav(activeTab: NeoRiderNavTab.home),
            ),
          ],
        ),
      ),
    );
  }

  Widget quickCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 52),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget statItem(IconData icon, String value, String title, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 34),
        const SizedBox(height: 10),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  Widget statBox(IconData icon, String title, String value, Color color) {
    return Container(
      width: 145,
      height: 95,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String title, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? green : Colors.white70, size: 32),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: active ? green : Colors.white70,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
