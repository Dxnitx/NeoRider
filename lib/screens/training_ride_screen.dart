import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';

class TrainingRideScreen extends StatelessWidget {
  const TrainingRideScreen({super.key});

  static const Color dark = Color(0xFF00131D);
  static const Color blue = Color(0xFF2D8CFF);
  static const Color lightBg = Color(0xFFF4F6F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _scoreCard(),
                    const SizedBox(height: 18),
                    _rideSummary(),
                    const SizedBox(height: 18),
                    _performanceInsights(),
                    const SizedBox(height: 18),
                    _trainingZones(),
                    const SizedBox(height: 18),
                    _tipsCard(),
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
        child: NeoRiderBottomNav(
          activeTab: NeoRiderNavTab.rides,
        ),
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
            'Training Ride',
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

  Widget _scoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
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
                    value: 0.78,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(blue),
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '78%',
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
          const SizedBox(width: 26),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Training Ride!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You maintained good safety habits and consistent performance. Keep training and stay safe!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_user, color: blue, size: 78),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                icon: Icons.access_time,
                value: '32 min',
                label: 'Ride Time',
              ),
              _SummaryItem(
                icon: Icons.speed,
                value: '22 km/h',
                label: 'Avg Speed',
              ),
              _SummaryItem(
                icon: Icons.route,
                value: '12 km',
                label: 'Distance',
              ),
              _SummaryItem(
                icon: Icons.local_fire_department,
                value: '410 kcal',
                label: 'Calories',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _performanceInsights() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.trending_up, 'Performance Insights'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: 0.78,
                              strokeWidth: 10,
                              backgroundColor: blue.withValues(alpha: 0.12),
                              valueColor: const AlwaysStoppedAnimation(blue),
                            ),
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '78%',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              Text(
                                'Safety Score',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: blue.withValues(alpha: 0.2)),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Keep it up!',
                            style: TextStyle(
                              color: blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "You're getting better\nwith every ride.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _InsightRow(
                      icon: Icons.adjust,
                      title: 'Consistency',
                      subtitle: 'Great! You maintained steady speed throughout the ride.',
                    ),
                    Divider(height: 28),
                    _InsightRow(
                      icon: Icons.trending_up,
                      title: 'Improvement',
                      subtitle: 'Your average speed is higher than your last 3 rides.',
                    ),
                    Divider(height: 28),
                    _InsightRow(
                      icon: Icons.access_time,
                      title: 'Endurance',
                      subtitle: 'Great ride time! Keep building your stamina.',
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

  Widget _trainingZones() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.monitor_heart_outlined, 'Training Zones'),
          const SizedBox(height: 20),
          const _ZoneRow(
            color: Colors.red,
            title: 'High Intensity',
            subtitle: '> 80% Max HR',
            value: 0.25,
            time: '8 min',
            percent: '25%',
          ),
          const _ZoneRow(
            color: Colors.orange,
            title: 'Moderate',
            subtitle: '60% - 80% Max HR',
            value: 0.44,
            time: '14 min',
            percent: '44%',
          ),
          const _ZoneRow(
            color: Colors.green,
            title: 'Aerobic',
            subtitle: '40% - 60% Max HR',
            value: 0.25,
            time: '8 min',
            percent: '25%',
          ),
          const _ZoneRow(
            color: blue,
            title: 'Recovery',
            subtitle: '< 40% Max HR',
            value: 0.06,
            time: '2 min',
            percent: '6%',
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.info, color: blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Based on estimated heart rate zones.',
                style: TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.lightbulb_outline, 'Training Tips'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: blue.withValues(alpha: 0.25)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Great effort! To improve further:\n\n'
                    '- Include interval sessions for speed\n'
                    '- Stay hydrated before and after rides\n'
                    '- Focus on smooth acceleration and braking',
                    style: TextStyle(fontSize: 15, height: 1.35),
                  ),
                ),
                Icon(Icons.two_wheeler, color: blue, size: 70),
              ],
            ),
          ),
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
        Icon(icon, color: blue, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
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
        Icon(icon, color: TrainingRideScreen.blue, size: 32),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: TrainingRideScreen.blue.withValues(alpha: 0.12),
          child: Icon(icon, color: TrainingRideScreen.blue, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 28),
      ],
    );
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.time,
    required this.percent,
  });

  final Color color;
  final String title;
  final String subtitle;
  final double value;
  final String time;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          CircleAvatar(radius: 7, backgroundColor: color),
          const SizedBox(width: 14),
          SizedBox(
            width: 125,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: Colors.grey.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 45,
            child: Text(time, style: const TextStyle(fontSize: 13)),
          ),
          Text(percent, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
