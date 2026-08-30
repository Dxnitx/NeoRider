import 'package:flutter/material.dart';

class SetupProgress extends StatelessWidget {
  const SetupProgress({super.key, required this.active});
  final int active;
  @override
  Widget build(BuildContext context) {
    const labels = ['Search Helmet', 'Place Chest IMU', 'Check Sensors'];
    return Row(
      children: List.generate(3, (index) {
        final step = index + 1;
        final selected = step == active;
        final done = step < active;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Divider(
                        color: done || selected
                            ? const Color(0xFF29B84A)
                            : Colors.black12,
                      ),
                    ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: selected
                        ? const Color(0xFF29B84A)
                        : const Color(0xFFE8EDF2),
                    child: Text(
                      done ? '✓' : '$step',
                      style: TextStyle(
                        color: selected || done
                            ? (selected
                                  ? Colors.white
                                  : const Color(0xFF29B84A))
                            : const Color(0xFF657184),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (index < 2)
                    Expanded(
                      child: Divider(
                        color: done ? const Color(0xFF29B84A) : Colors.black12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF29B84A)
                      : const Color(0xFF657184),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
