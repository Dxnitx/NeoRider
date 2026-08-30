import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.text,
    this.active = true,
    this.color,
  });
  final String text;
  final bool active;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final value =
        color ?? (active ? const Color(0xFF29B84A) : const Color(0xFF657184));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: value.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: value.withValues(alpha: .25)),
      ),
      child: Text(
        text,
        style: TextStyle(color: value, fontWeight: FontWeight.bold),
      ),
    );
  }
}
