import 'package:flutter/material.dart';
import 'neorider_card.dart';

class AccidentProgressCard extends StatelessWidget {
  const AccidentProgressCard({super.key, required this.streak});
  final int streak;
  @override
  Widget build(BuildContext context) {
    final value = streak.clamp(0, 3);
    return NeoRiderCard(
      child: Column(
        children: [
          const Text(
            'Accident Confirmation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '$value / 3',
            style: const TextStyle(
              color: Color(0xFFFF8A00),
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          LinearProgressIndicator(
            value: value / 3,
            color: const Color(0xFFFF8A00),
          ),
        ],
      ),
    );
  }
}
