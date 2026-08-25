import 'package:flutter/material.dart';

import '../models/safety_status.dart';

class SafetyStatusCard extends StatelessWidget {
  const SafetyStatusCard({super.key, required this.status});

  final SafetyStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status.state) {
      RiderSafetyState.safe => (
        const Color(0xFF24B53A),
        Icons.verified_user,
        'SAFE',
      ),
      RiderSafetyState.risk => (
        Colors.orange,
        Icons.warning_amber_rounded,
        'RISK',
      ),
      RiderSafetyState.accident => (Colors.red, Icons.emergency, 'ACCIDENT'),
      RiderSafetyState.unknown => (
        Colors.blueGrey,
        Icons.shield_outlined,
        'WAITING',
      ),
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NeoRider Safety Status',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            status.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(status.message),
          const Divider(height: 24),
          _Detail(label: 'Prediction', value: status.rawPrediction),
          _Detail(
            label: 'Confidence',
            value: status.confidence == null
                ? '--'
                : '${(status.confidence! * 100).toStringAsFixed(1)}%',
          ),
          _Detail(
            label: 'Last updated',
            value: status.state == RiderSafetyState.unknown
                ? '--'
                : _time(status.receivedAt),
          ),
        ],
      ),
    );
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
