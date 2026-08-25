import 'package:flutter/material.dart';

import '../widgets/neorider_bottom_nav.dart';
import '../utils/responsive.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static const Color dark = Color(0xFF00131D);
  static const Color red = Color(0xFFFF3B30);
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
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  responsive.sectionSpacing,
                  responsive.horizontalPadding,
                  responsive.sectionSpacing,
                ),
                child: Column(
                  children: [
                    _sosBanner(context),
                    const SizedBox(height: 18),
                    _contactsCard(context),
                    const SizedBox(height: 18),
                    _sosInfoCard(context),
                    const SizedBox(height: 18),
                    _shareLocationCard(context),
                    const SizedBox(height: 18),
                    _safetyTipsCard(context),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: NeoRiderBottomNav(activeTab: null),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      color: dark,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 34),
          ),
          SizedBox(width: responsive.isSmallPhone ? 14 : 22),
          Text(
            'Emergency',
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.pageTitleSize.clamp(26, 32),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, color: Colors.white, size: 34),
              Positioned(
                right: -6,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sosBanner(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Need Help?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tap the SOS button to alert your emergency contacts and share your live location.',
          style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
        ),
      ],
    );
    final sosButton = Semantics(
      button: true,
      label: 'Send emergency SOS alert',
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: responsive.isSmallPhone ? 112 : 126,
          height: responsive.isSmallPhone ? 112 : 126,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFF1E14),
            boxShadow: [
              BoxShadow(
                color: red.withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap to Alert',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A0000), Color(0xFF4D0000)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: responsive.width < 430
          ? Column(children: [intro, const SizedBox(height: 20), sosButton])
          : Row(
              children: [
                Expanded(child: intro),
                const SizedBox(width: 20),
                sosButton,
              ],
            ),
    );
  }

  Widget _contactsCard(BuildContext context) {
    return _whiteCard(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.groups_rounded, color: red, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Emergency Contacts',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Manage',
                style: TextStyle(
                  color: red,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ContactRow(
            initials: 'RM',
            name: 'Amma🤍✨',
            phone: '+91 98765 43210',
          ),
          const Divider(height: 26),
          const _ContactRow(
            initials: 'PS',
            name: 'Tattha🤍✨',
            phone: '+91 91234 56789',
          ),
          const Divider(height: 26),
          const _ContactRow(initials: 'AK', name: 'Ambulance', phone: '110'),
        ],
      ),
    );
  }

  Widget _sosInfoCard(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: red.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: red.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: red, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'What Happens When You Tap SOS?',
                  style: TextStyle(
                    color: red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          responsive.isSmallPhone
              ? Column(
                  children: const [
                    _SosStep(
                      icon: Icons.location_on,
                      text: 'Your live location is shared',
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 32,
                    ),
                    _SosStep(
                      icon: Icons.notifications_active,
                      text: 'Alert sent to all contacts',
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 32,
                    ),
                    _SosStep(
                      icon: Icons.phone_in_talk,
                      text: 'Contacts can call you',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _SosStep(
                        icon: Icons.location_on,
                        text: 'Your live location\nis shared',
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey, size: 38),
                    Expanded(
                      child: _SosStep(
                        icon: Icons.notifications_active,
                        text: 'Alert sent to all\ncontacts',
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey, size: 38),
                    Expanded(
                      child: _SosStep(
                        icon: Icons.phone_in_talk,
                        text: 'Contacts can\ncall you',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _shareLocationCard(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    return _whiteCard(
      child: Flex(
        direction: responsive.isSmallPhone ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: responsive.isSmallPhone
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          if (!responsive.isSmallPhone)
            const Icon(Icons.location_on, color: red, size: 36),
          if (!responsive.isSmallPhone) const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Live Location',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Share your real-time location with your contacts.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (responsive.isSmallPhone) const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: red, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            ),
            onPressed: () {},
            child: const Text(
              'Share Now',
              style: TextStyle(
                color: red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyTipsCard(BuildContext context) {
    return _whiteCard(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: red, size: 30),
              SizedBox(width: 12),
              Text(
                'Safety Tips',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          _TipRow(
            icon: Icons.wb_sunny,
            text: 'Stay in well-lit and busy areas',
          ),
          Divider(height: 24),
          _TipRow(
            icon: Icons.sports_motorsports,
            text: 'Always wear your helmet',
          ),
          Divider(height: 24),
          _TipRow(
            icon: Icons.phonelink_erase,
            text: 'Avoid using phone while riding',
          ),
          Divider(height: 24),
          _TipRow(
            icon: Icons.visibility,
            text: 'Stay alert and aware of your surroundings',
          ),
        ],
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
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.initials,
    required this.name,
    required this.phone,
  });

  final String initials;
  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final responsive = NeoResponsive.of(context);
    final avatar = CircleAvatar(
      radius: responsive.isSmallPhone ? 27 : 35,
      backgroundColor: EmergencyScreen.red.withValues(alpha: 0.10),
      child: Text(
        initials,
        style: const TextStyle(
          color: EmergencyScreen.red,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    final details = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(phone, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          icon: Icons.phone,
          color: EmergencyScreen.green,
          borderColor: EmergencyScreen.green.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 10),
        _CircleIconButton(
          icon: Icons.chat_bubble,
          color: EmergencyScreen.red,
          borderColor: EmergencyScreen.red.withValues(alpha: 0.45),
        ),
      ],
    );
    if (responsive.isSmallPhone) {
      return Column(
        children: [
          Row(children: [avatar, const SizedBox(width: 14), details]),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      );
    }
    return Row(children: [avatar, const SizedBox(width: 22), details, actions]);
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.borderColor,
  });

  final IconData icon;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

class _SosStep extends StatelessWidget {
  const _SosStep({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: EmergencyScreen.red.withValues(alpha: 0.10),
          child: Icon(icon, color: EmergencyScreen.red, size: 34),
        ),
        const SizedBox(height: 14),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.3),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: EmergencyScreen.red, size: 30),
        const SizedBox(width: 20),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 17))),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 30),
      ],
    );
  }
}
