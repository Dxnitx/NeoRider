import 'package:flutter/material.dart';

enum NeoRiderNavTab { home, rides, liveRide, alerts, profile }

class NeoRiderBottomNav extends StatelessWidget {
  const NeoRiderBottomNav({super.key, required this.activeTab});

  final NeoRiderNavTab? activeTab;

  static const Color green = Color(0xFF39D353);
  static const Color dark = Color(0xFF02111D);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: _NavButton(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isActive: activeTab == NeoRiderNavTab.home,
                    onTap: () => _goTo(context, '/home'),
                  ),
                ),
                Expanded(
                  child: _NavButton(
                    icon: Icons.route,
                    label: 'Rides',
                    isActive: activeTab == NeoRiderNavTab.rides,
                    onTap: () => _goTo(context, '/rides'),
                  ),
                ),
                const SizedBox(width: 68),
                Expanded(
                  child: Stack(
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
                ),
                Expanded(
                  child: _NavButton(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    isActive: activeTab == NeoRiderNavTab.profile,
                    onTap: () => _goTo(context, '/profile'),
                  ),
                ),
              ],
            ),
            Positioned(
              top: -20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _goTo(context, '/live-ride'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _StartRideButton(),
                    const SizedBox(height: 2),
                    Text(
                      'Start Ride',
                      style: TextStyle(
                        color: activeTab == NeoRiderNavTab.liveRide
                            ? green
                            : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
      width: 62,
      height: 62,
      decoration: const BoxDecoration(
        color: NeoRiderBottomNav.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.sports_motorsports,
        color: Colors.white,
        size: 32,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? NeoRiderBottomNav.green : Colors.white70,
              size: 25,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: isActive ? NeoRiderBottomNav.green : Colors.white70,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
