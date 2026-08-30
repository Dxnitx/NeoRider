import 'package:flutter/material.dart';

class NeoRiderHeader extends StatelessWidget {
  const NeoRiderHeader({super.key, this.label, this.emergency = false});
  final String? label;
  final bool emergency;

  @override
  Widget build(BuildContext context) => Container(
    height: 112,
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF041522), Color(0xFF00101C)]),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        Image.asset(
          'assets/images/neorider_logo.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NeoRider',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Ride Smart, Ride Safe',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        if (label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: emergency ? const Color(0xFFED2B2F) : Colors.white10,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    ),
  );
}
