import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';

class HighSpeedAlertScreen extends StatelessWidget {
  const HighSpeedAlertScreen({super.key});

  static const Color dark = Color(0xFF00131D);
  static const Color orange = Color(0xFFFF9800);
  static const Color bg = Color(0xFFF5F6F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _alertCard(),
                    const SizedBox(height: 18),
                    _overviewCard(),
                    const SizedBox(height: 18),
                    _mapCard(),
                    const SizedBox(height: 18),
                    _tipCard(),
                    const SizedBox(height: 18),
                    _actionsCard(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: NeoRiderBottomNav(
          activeTab: NeoRiderNavTab.alerts,
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      height: 84,
      color: dark,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 34,
            ),
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
    return _card(
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: orange.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: orange,
              size: 64,
            ),
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High Speed Alert',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Warning',
                      style: TextStyle(
                        color: orange,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: orange,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'You exceeded 80 km/h at 8:20 AM.\nStay within safe speed limits.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'May 8, 2026 - 8:20 AM',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.list_alt, 'Overview'),
          const SizedBox(height: 24),
          const Text(
            'A high speed event was detected during your ride.\nDriving above safe speed limits can be dangerous.',
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _OverviewItem(
                icon: Icons.access_time,
                value: '8:20 AM',
                label: 'Time',
              ),
              _OverviewItem(
                icon: Icons.calendar_month,
                value: 'May 8, 2026',
                label: 'Date',
              ),
              _OverviewItem(
                icon: Icons.speed,
                value: '92 km/h',
                label: 'Top Speed',
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
    return _card(
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
                Container(
                  height: 260,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: Image.network(
                    'https://i.imgur.com/z8d7P6B.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: orange.withValues(alpha: 0.25),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: orange,
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

  Widget _tipCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.shield, 'Safety Tip'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: orange.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.lightbulb,
                    color: orange,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Text(
                    'Always follow speed limits for your safety and the safety of others. Adjust your speed to road conditions.',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
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

  Widget _actionsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.list_alt, 'What You Can Do'),
          const SizedBox(height: 18),
          const _ActionRow(
            icon: Icons.speed,
            text: 'Follow speed limits',
          ),
          const Divider(height: 28),
          const _ActionRow(
            icon: Icons.add_road,
            text: 'Adjust speed to road conditions',
          ),
          const Divider(height: 28),
          const _ActionRow(
            icon: Icons.shield,
            text: 'Stay alert and drive safely',
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
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
        Icon(icon, color: orange, size: 30),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
        Icon(
          icon,
          color: HighSpeedAlertScreen.orange,
          size: 34,
        ),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: HighSpeedAlertScreen.orange,
          size: 30,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 19,
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 34,
        ),
      ],
    );
  }
}
