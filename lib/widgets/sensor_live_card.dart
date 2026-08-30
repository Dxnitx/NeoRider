import 'package:flutter/material.dart';
import '../models/ble_sensor_reading.dart';
import 'neorider_card.dart';
import 'status_pill.dart';

class SensorLiveCard extends StatelessWidget {
  const SensorLiveCard({
    super.key,
    required this.title,
    required this.reading,
    required this.live,
    required this.icon,
  });
  final String title;
  final BleSensorReading? reading;
  final bool live;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final r = reading;
    final values = [
      r?.accelX,
      r?.accelY,
      r?.accelZ,
      r?.gyroX,
      r?.gyroY,
      r?.gyroZ,
    ];
    const labels = [
      'AX (g)',
      'AY (g)',
      'AZ (g)',
      'GX (°/s)',
      'GY (°/s)',
      'GZ (°/s)',
    ];
    return NeoRiderCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEAF8EE),
                child: Icon(icon, color: const Color(0xFF29B84A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusPill(text: live ? 'LIVE' : 'WAITING', active: live),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (_, i) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labels[i],
                  style: const TextStyle(
                    color: Color(0xFF657184),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  values[i]?.toStringAsFixed(2) ?? '--',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
