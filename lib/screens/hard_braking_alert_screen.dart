import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';
import '../utils/responsive.dart';

class HardBrakingAlertScreen extends StatelessWidget {
  const HardBrakingAlertScreen({super.key});

  static const Color dark = Color(0xFF00131D);
  static const Color red = Color(0xFFFF3B30);
  static const Color bg = Color(0xFFF4F6F6);

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  children: [
                    _alertCard(),
                    const SizedBox(height: 18),
                    _overviewCard(),
                    const SizedBox(height: 18),
                    _mapCard(),
                    const SizedBox(height: 18),
                    _safetyTipCard(),
                    const SizedBox(height: 18),
                    _actionsCard(),
                    SizedBox(height: responsive.sectionSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: NeoRiderBottomNav(activeTab: NeoRiderNavTab.alerts),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      height: 82,
      color: dark,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 22),
          const Text(
            'Alert Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard() {
    return _whiteCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: red.withValues(alpha: 0.10),
            ),
            child: const Icon(Icons.shield, color: red, size: 42),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hard Braking Detected',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Critical',
                      style: TextStyle(
                        color: red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 5, backgroundColor: red),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Hard braking detected at 8:45 AM.\nPlease ride carefully.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'May 8, 2026 - 8:45 AM',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.list_alt, 'Overview'),
          const SizedBox(height: 24),
          const Text(
            'A hard braking event was detected during your ride.\nFrequent hard braking can increase the risk of accidents.',
            style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 26),
          const Divider(),
          const SizedBox(height: 24),
          const Wrap(
            alignment: WrapAlignment.spaceAround,
            runSpacing: 18,
            spacing: 18,
            children: [
              _OverviewItem(
                icon: Icons.access_time,
                value: '8:45 AM',
                label: 'Time',
              ),
              _OverviewItem(
                icon: Icons.calendar_month,
                value: 'May 8, 2026',
                label: 'Date',
              ),
              _OverviewItem(
                icon: Icons.speed,
                value: '68 km/h',
                label: 'Speed Before',
              ),
              _OverviewItem(
                icon: Icons.location_on,
                value: 'MG Road',
                label: 'Location',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.location_on, 'Event on Map'),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  'https://maps.gstatic.com/tactile/basepage/pegman_sherlock.png',
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: red.withValues(alpha: 0.25),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.priority_high,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyTipCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.shield, 'Safety Tip'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: red.withValues(alpha: 0.12),
                  child: const Icon(Icons.lightbulb, color: red, size: 34),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Text(
                    'Try to anticipate stops and slow down gradually.\nKeep a safe distance from other vehicles.',
                    style: TextStyle(fontSize: 18, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.list_alt, 'What You Can Do'),
          const SizedBox(height: 18),
          const _ActionRow(icon: Icons.speed, text: 'Maintain safe speed'),
          const Divider(height: 26),
          const _ActionRow(
            icon: Icons.do_not_disturb_on,
            text: 'Avoid sudden braking',
          ),
          const Divider(height: 26),
          const _ActionRow(icon: Icons.shield, text: 'Stay alert and focused'),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: red, size: 30),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: HardBrakingAlertScreen.red, size: 34),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: HardBrakingAlertScreen.red, size: 30),
        const SizedBox(width: 18),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 19))),
        const Icon(Icons.chevron_right, size: 34, color: Colors.grey),
      ],
    );
  }
}
