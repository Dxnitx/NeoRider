import 'package:flutter/material.dart';

enum NeoRiderNavTab {
  home,
  rides,
  liveRide,
  alerts,
  profile,
}

class NeoRiderBottomNav extends StatelessWidget {
  const NeoRiderBottomNav({
    super.key,
    required this.activeTab,
  });

  final NeoRiderNavTab? activeTab;

  static const Color green = Color(0xFF39D353);
  static const Color dark = Color(0xFF02111D);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavButton(
            icon: Icons.home_outlined,
            label: 'Home',
            isActive: activeTab == NeoRiderNavTab.home,
            onTap: () => _goTo(context, '/home'),
          ),
          _NavButton(
            icon: Icons.route,
            label: 'Rides',
            isActive: activeTab == NeoRiderNavTab.rides,
            onTap: () => _goTo(context, '/rides'),
          ),
          Transform.translate(
            offset: const Offset(0, -24),
            child: GestureDetector(
              onTap: () => _goTo(context, '/live-ride'),
              child: Column(
                children: [
                  const _StartRideButton(),
                  const SizedBox(height: 4),
                  Text(
                    'Start Ride',
                    style: TextStyle(
                      color: activeTab == NeoRiderNavTab.liveRide
                          ? green
                          : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _NavButton(
                icon: activeTab == NeoRiderNavTab.alerts
                    ? Icons.notifications
                    : Icons.notifications_none,
                label: 'Alerts',
                isActive: activeTab == NeoRiderNavTab.alerts,
                onTap: () => _goTo(context, '/alerts'),
              ),
              Positioned(
                right: 12,
                top: 7,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _NavButton(
            icon: Icons.person_outline,
            label: 'Profile',
            isActive: activeTab == NeoRiderNavTab.profile,
            onTap: () => _goTo(context, '/profile'),
          ),
        ],
      ),
    );
  }

  void _goTo(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == routeName) {
      return;
    }

    Navigator.pushReplacementNamed(context, routeName);
  }
}

class _StartRideButton extends StatelessWidget {
  const _StartRideButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: const BoxDecoration(
        color: NeoRiderBottomNav.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.sports_motorsports,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? NeoRiderBottomNav.green : Colors.white70,
            size: 31,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? NeoRiderBottomNav.green : Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
