import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color green = Color(0xFF39D353);
  static const Color dark = Color(0xFF02111D);

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 125),
                      child: Column(
                        children: [
                          _profileHeader(),
                          const SizedBox(height: 24),
                          _statsCard(),
                          const SizedBox(height: 24),
                          _menuCard(),
                          const SizedBox(height: 24),
                          _signOutButton(),
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
              child: const NeoRiderBottomNav(
                activeTab: NeoRiderNavTab.profile,
              ),
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
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none, color: Colors.white, size: 36),
              Positioned(
                right: -3,
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

  Widget _profileHeader() {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage("assets/images/profile_rider.png"),
            ),
            Positioned(
              right: -2,
              bottom: 3,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rider",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1522),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "rider@example.com",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F7E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, color: green, size: 18),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          "Premium Member",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.black54),
      ],
    );
  }

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _statItem(Icons.shield_outlined, "85%", "Safety Score", green),
          ),
          _divider(),
          Expanded(
            child: _statItem(Icons.route, "120 km", "Total Distance", Colors.blue),
          ),
          _divider(),
          Expanded(
            child: _statItem(Icons.access_time, "8h 45m", "Total Time", Colors.orange),
          ),
          _divider(),
          Expanded(
            child: _statItem(
              Icons.sports_motorsports,
              "24",
              "Total Rides",
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 34),
        const SizedBox(height: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D1522),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 75,
      color: Colors.black12,
    );
  }

  Widget _menuCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _menuItem(
            Icons.person,
            "Personal Information",
            "Update your personal details",
            green,
            const Color(0xFFE4F8E8),
          ),
          _menuItem(
            Icons.sports_motorsports,
            "Helmet & Device",
            "Manage your connected helmet",
            Colors.blue,
            const Color(0xFFE4F1FF),
          ),
          _menuItem(
            Icons.track_changes,
            "Ride Goals",
            "Set and track your goals",
            Colors.orange,
            const Color(0xFFFFF0D8),
          ),
          _menuItem(
            Icons.bar_chart,
            "Ride Statistics",
            "View detailed ride analytics",
            Colors.purple,
            const Color(0xFFF0E6FF),
          ),
          _menuItem(
            Icons.notifications,
            "Alert Preferences",
            "Customize your alert settings",
            Colors.red,
            const Color(0xFFFFE8EA),
          ),
          _menuItem(
            Icons.lock,
            "Privacy & Security",
            "Manage your privacy and security",
            Colors.teal,
            const Color(0xFFE0F7F4),
          ),
          _menuItem(
            Icons.help,
            "Help & Support",
            "Get help and contact support",
            Colors.amber,
            const Color(0xFFFFF3D8),
          ),
          _menuItem(
            Icons.settings,
            "Settings",
            "App settings and preferences",
            Colors.grey,
            const Color(0xFFF1F1F1),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Color bgColor, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D1522),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: 20,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 90, right: 18),
            child: Divider(
              color: Colors.grey.withValues(alpha: 0.25),
              height: 1,
            ),
          ),
      ],
    );
  }

  Widget _signOutButton() {
    return Container(
      height: 64,
      decoration: _cardDecoration(),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 26),
            SizedBox(width: 12),
            Text(
              "Sign Out",
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.055),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
