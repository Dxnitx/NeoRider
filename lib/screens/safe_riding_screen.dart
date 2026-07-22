import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';

class SafeRidingScreen extends StatelessWidget {
  const SafeRidingScreen({super.key});

  static const Color dark = Color(0xFF00131D);
  static const Color green = Color(0xFF34D058);
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
                    _safetyHighlights(),
                    const SizedBox(height: 18),
                    _scoreHistory(),
                    const SizedBox(height: 18),
                    _tipCard(),
                    const SizedBox(height: 18),
                    _bottomButton(context),
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
            'Safe Riding',
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
                    value: 0.85,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(green),
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '85%',
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
                  'Great Ride!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "You're a responsible rider. Keep following safe riding practices to stay protected on the road.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_user, color: green, size: 78),
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
                value: '45 min',
                label: 'Ride Time',
              ),
              _SummaryItem(
                icon: Icons.speed,
                value: '24 km/h',
                label: 'Avg Speed',
              ),
              _SummaryItem(
                icon: Icons.route,
                value: '18 km',
                label: 'Distance',
              ),
              _SummaryItem(
                icon: Icons.flag,
                value: '0',
                label: 'Incidents',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _safetyHighlights() {
    final items = [
      ['Helmet Usage', 'Always wear a helmet', Icons.sports_motorsports],
      ['Speed Control', 'Maintained safe speeds', Icons.speed],
      ['Smooth Braking', 'Braked smoothly', Icons.radio_button_checked],
      ['Smooth Cornering', 'Took turns safely', Icons.turn_right],
      ['Phone Usage', 'Did not use phone while riding', Icons.phonelink_erase],
    ];

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.shield_outlined, 'Safety Highlights'),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: green.withValues(alpha: 0.15),
                      child: Icon(item[2] as IconData, color: green, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item[0] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item[1] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Good',
                      style: TextStyle(
                        color: green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.chevron_right, size: 30),
                  ],
                ),
                if (item != items.last)
                  const Padding(
                    padding: EdgeInsets.only(left: 76, top: 12, bottom: 12),
                    child: Divider(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreHistory() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.trending_up, 'Safety Score History'),
          const SizedBox(height: 20),
          SizedBox(
            height: 210,
            child: CustomPaint(
              painter: ScoreChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: green.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: green.withValues(alpha: 0.15),
            child: const Icon(Icons.lightbulb_outline, color: green),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe Riding Tip',
                  style: TextStyle(
                    color: green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Maintain a safe distance from other vehicles and follow traffic rules at all times.',
                  style: TextStyle(fontSize: 15, height: 1.3),
                ),
              ],
            ),
          ),
          const Icon(Icons.two_wheeler, color: green, size: 58),
        ],
      ),
    );
  }

  Widget _bottomButton(BuildContext context) {
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
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Go Back',
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
        Icon(icon, color: green, size: 28),
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
        Icon(icon, color: SafeRidingScreen.green, size: 32),
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

class ScoreChartPainter extends CustomPainter {
  final List<double> scores = [72, 68, 75, 80, 64, 78, 85];
  final List<String> dates = [
    'May 2',
    'May 3',
    'May 4',
    'May 5',
    'May 6',
    'May 7',
    'May 8',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = SafeRidingScreen.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorder = Paint()
      ..color = SafeRidingScreen.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final left = 45.0;
    final top = 10.0;
    final chartWidth = size.width - 60;
    final chartHeight = size.height - 45;

    for (int i = 0; i <= 4; i++) {
      final y = top + (chartHeight / 4) * i;
      canvas.drawLine(Offset(left, y), Offset(left + chartWidth, y), gridPaint);
    }

    final points = <Offset>[];

    for (int i = 0; i < scores.length; i++) {
      final x = left + (chartWidth / (scores.length - 1)) * i;
      final y = top + chartHeight - (scores[i] / 100) * chartHeight;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 6, dotPaint);
      canvas.drawCircle(points[i], 6, dotBorder);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${scores[i].toInt()}%',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(points[i].dx - 14, points[i].dy - 30));

      final datePainter = TextPainter(
        text: TextSpan(
          text: dates[i],
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      datePainter.paint(canvas, Offset(points[i].dx - 18, size.height - 25));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
