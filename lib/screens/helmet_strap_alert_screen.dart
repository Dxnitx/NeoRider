import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';

class HelmetStrapAlertScreen extends StatelessWidget {
  const HelmetStrapAlertScreen({super.key});

  static const Color dark = Color(0xFF00131D);
  static const Color blue = Color(0xFF2D8CFF);
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
    return _card(
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: blue.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.notifications, color: blue, size: 64),
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Helmet Strap Reminder',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Info',
                      style: TextStyle(
                        color: blue,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 5, backgroundColor: blue),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Please fasten your helmet strap\nfor your safety.',
                  style: TextStyle(color: Colors.grey, fontSize: 18, height: 1.4),
                ),
                SizedBox(height: 18),
                Text(
                  'May 8, 2026 - 8:10 AM',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
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
            'Our system detected that your helmet strap was not fastened during your ride. Always wear your helmet properly for safety.',
            style: TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _OverviewItem(
                icon: Icons.access_time,
                value: '8:10 AM',
                label: 'Time',
              ),
              _OverviewItem(
                icon: Icons.calendar_month,
                value: 'May 8, 2026',
                label: 'Date',
              ),
              _OverviewItem(
                icon: Icons.sports_motorsports,
                value: 'Not Fastened',
                label: 'Status',
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
                    color: blue.withValues(alpha: 0.25),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: blue,
                      ),
                      child: const Icon(
                        Icons.sports_motorsports,
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
              color: blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: blue.withValues(alpha: 0.15),
                  child: const Icon(Icons.lightbulb, color: blue, size: 34),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Text(
                    'Always fasten your helmet strap properly.\nIt can protect you in case of an accident.',
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
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.list_alt, 'What You Can Do'),
          const SizedBox(height: 18),
          const _ActionRow(
            icon: Icons.sports_motorsports,
            text: 'Fasten your helmet strap',
          ),
          const Divider(height: 28),
          const _ActionRow(
            icon: Icons.shield,
            text: 'Wear helmet before every ride',
          ),
          const Divider(height: 28),
          const _ActionRow(icon: Icons.person, text: 'Make safety a habit'),
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
        Icon(icon, color: blue, size: 30),
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
        Icon(icon, color: HelmetStrapAlertScreen.blue, size: 34),
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
        Icon(icon, color: HelmetStrapAlertScreen.blue, size: 30),
        const SizedBox(width: 18),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 19))),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 34),
      ],
    );
  }
}
