import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';
import '../utils/responsive.dart';

class EveningRideScreen extends StatelessWidget {
  const EveningRideScreen({super.key});

  static const Color dark = Color(0xFF00131D);
  static const Color orange = Color(0xFFFF8A00);
  static const Color red = Color(0xFFFF2D2D);
  static const Color green = Color(0xFF34D058);
  static const Color lightBg = Color(0xFFF4F6F6);

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Scaffold(
      backgroundColor: lightBg,
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
                    _scoreCard(context),
                    const SizedBox(height: 18),
                    _rideSummary(),
                    const SizedBox(height: 18),
                    _riskInsights(),
                    const SizedBox(height: 18),
                    _scoreBreakdown(),
                    const SizedBox(height: 18),
                    _tipCard(),
                    const SizedBox(height: 18),
                    _bottomButton(),
                  ],
                ),
              ),
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

  Widget _topBar(BuildContext context) {
    return Container(
      height: 70,
      color: dark,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 24),
          const Text(
            'Evening Ride',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Flex(
        direction: responsive.width < 600 ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 135,
            height: 135,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 135,
                  height: 135,
                  child: CircularProgressIndicator(
                    value: 0.64,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(orange),
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '64%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Safety Score',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: responsive.width < 600 ? 0 : 26,
            height: responsive.width < 600 ? 18 : 0,
          ),
          SizedBox(
            width: responsive.width < 600
                ? double.infinity
                : responsive.width - 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Alert!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "You faced a few risks during this ride. Review the details below and let's make your next ride safer.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: responsive.width < 600 ? 0 : 14,
            height: responsive.width < 600 ? 14 : 0,
          ),
          const Icon(Icons.warning_amber_rounded, color: orange, size: 58),
        ],
      ),
    );
  }

  Widget _rideSummary() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.assignment_turned_in_outlined, 'Ride Summary'),
          const SizedBox(height: 24),
          const Wrap(
            alignment: WrapAlignment.spaceAround,
            runSpacing: 18,
            spacing: 18,
            children: [
              _SummaryItem(
                icon: Icons.access_time,
                value: '58 min',
                label: 'Ride Time',
              ),
              _SummaryItem(
                icon: Icons.speed,
                value: '21 km/h',
                label: 'Avg Speed',
              ),
              _SummaryItem(
                icon: Icons.route,
                value: '21 km',
                label: 'Distance',
              ),
              _SummaryItem(
                icon: Icons.local_fire_department,
                value: '620 kcal',
                label: 'Calories',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riskInsights() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.warning_amber_rounded, 'Risk Insights'),
          const SizedBox(height: 20),
          const _RiskRow(
            icon: Icons.speed,
            title: 'High Speed',
            subtitle: 'You rode above safe speed limits\nin a few segments.',
            badge: 'Medium Risk',
            badgeColor: orange,
          ),
          const Divider(height: 26),
          const _RiskRow(
            icon: Icons.radio_button_checked,
            title: 'Hard Braking',
            subtitle: 'Frequent hard braking detected.\nTry to brake smoothly.',
            badge: 'Medium Risk',
            badgeColor: orange,
          ),
          const Divider(height: 26),
          const _RiskRow(
            icon: Icons.nightlight_round,
            title: 'Low Light Conditions',
            subtitle:
                'Riding in low light can reduce\nvisibility and increase risks.',
            badge: 'High Risk',
            badgeColor: red,
          ),
        ],
      ),
    );
  }

  Widget _scoreBreakdown() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Safety Score Breakdown',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              SizedBox(
                width: 155,
                height: 155,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 155,
                      height: 155,
                      child: CircularProgressIndicator(
                        value: 0.64,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.withValues(alpha: 0.18),
                        valueColor: const AlwaysStoppedAnimation(orange),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '64%',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: dark,
                          ),
                        ),
                        Text('Safety Score', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28),
              const Expanded(
                child: Column(
                  children: [
                    _BreakdownRow(
                      icon: Icons.sports_motorsports,
                      title: 'Helmet Usage',
                      status: 'Good',
                      color: green,
                    ),
                    Divider(height: 22),
                    _BreakdownRow(
                      icon: Icons.speed,
                      title: 'Speed Control',
                      status: 'Medium',
                      color: orange,
                    ),
                    Divider(height: 22),
                    _BreakdownRow(
                      icon: Icons.radio_button_checked,
                      title: 'Smooth Braking',
                      status: 'Poor',
                      color: red,
                    ),
                    Divider(height: 22),
                    _BreakdownRow(
                      icon: Icons.turn_right,
                      title: 'Cornering',
                      status: 'Medium',
                      color: orange,
                    ),
                    Divider(height: 22),
                    _BreakdownRow(
                      icon: Icons.phonelink_erase,
                      title: 'Phone Usage',
                      status: 'Good',
                      color: green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: orange.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: orange.withValues(alpha: 0.18),
            child: const Icon(Icons.lightbulb_outline, color: orange),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evening Ride Tip',
                  style: TextStyle(
                    color: dark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ride safe in the evening:\n'
                  '- Use front and rear lights\n'
                  '- Wear reflective gear\n'
                  '- Stay visible, stay safe',
                  style: TextStyle(fontSize: 15, height: 1.35),
                ),
              ],
            ),
          ),
          const Icon(Icons.directions_bike, color: orange, size: 66),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: () {},
        child: const Text(
          'View Ride Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
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
        Icon(icon, color: orange, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
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
        Icon(icon, color: EveningRideScreen.orange, size: 32),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: EveningRideScreen.orange.withValues(alpha: 0.13),
          child: Icon(icon, color: EveningRideScreen.orange, size: 28),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.chevron_right, size: 30),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.icon,
    required this.title,
    required this.status,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: color.withValues(alpha: 0.13),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
