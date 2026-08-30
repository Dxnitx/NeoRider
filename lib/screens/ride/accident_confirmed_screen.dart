import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/emergency_contact.dart';
import '../../services/emergency_call_service.dart';
import '../../services/emergency_contact_service.dart';
import '../../services/ride_session.dart';
import '../../widgets/neorider_card.dart';
import '../../widgets/neorider_header.dart';

class AccidentConfirmedScreen extends StatefulWidget {
  const AccidentConfirmedScreen({super.key});
  @override
  State<AccidentConfirmedScreen> createState() =>
      _AccidentConfirmedScreenState();
}

class _AccidentConfirmedScreenState extends State<AccidentConfirmedScreen> {
  final session = RideSession.instance;
  final calls = const EmergencyCallService();
  Timer? timer;
  EmergencyContact? contact;
  int seconds = 10;
  bool launching = false;
  @override
  void initState() {
    super.initState();
    _load();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (seconds > 1) {
        setState(() => seconds--);
      } else {
        timer?.cancel();
        _callContact();
      }
    });
  }

  Future<void> _load() async {
    final value = await const EmergencyContactService().primaryContact();
    if (mounted) setState(() => contact = value);
  }

  Future<void> _callContact() async {
    final phone = contact?.phone;
    if (phone == null || launching) return;
    setState(() => launching = true);
    await calls.openDialer(phone);
  }

  Future<void> _safe() async {
    timer?.cancel();
    await session.markSafe();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    body: SafeArea(
      child: Column(
        children: [
          const NeoRiderHeader(label: 'EMERGENCY', emergency: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFED2B2F), Color(0xFF8D1013)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 78,
                        ),
                        Text(
                          'ACCIDENT DETECTED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'A possible motorcycle accident has been confirmed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeoRiderCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AUTOMATIC EMERGENCY RESPONSE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _state(
                          'Helmet Sensor',
                          session.helmetSensorReceiving ? 'Active' : 'Offline',
                          true,
                        ),
                        _state(
                          'Chest Sensor',
                          session.chestSensorReceiving ? 'Active' : 'Offline',
                          true,
                        ),
                        _state('Final State', 'ACCIDENT_CONFIRMED', false),
                        _state('Vibration', 'Active', false),
                        _state('Buzzer', 'Active', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeoRiderCard(
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.call,
                              color: Color(0xFFED2B2F),
                              size: 32,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Calling Emergency Contact',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          contact?.name ?? 'Loading contact...',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          _masked(contact?.phone ?? ''),
                          style: const TextStyle(
                            color: Color(0xFF657184),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 18),
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFFFDEBEC),
                          child: const Icon(
                            Icons.phone,
                            color: Color(0xFFED2B2F),
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          launching
                              ? 'Opening phone call workflow...'
                              : 'Calling in ${seconds}s',
                          style: const TextStyle(
                            color: Color(0xFFED2B2F),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            Icon(Icons.location_off, color: Color(0xFF657184)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Location sharing unavailable'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFED2B2F),
                      ),
                      onPressed:
                          EmergencyCallService.emergencyServicesNumber.isEmpty
                          ? null
                          : () => calls.openDialer(
                              EmergencyCallService.emergencyServicesNumber,
                            ),
                      icon: const Icon(Icons.call),
                      label: const Text('CALL EMERGENCY SERVICES'),
                    ),
                  ),
                  if (EmergencyCallService.emergencyServicesNumber.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Emergency services number is not configured.',
                        style: TextStyle(color: Color(0xFF657184)),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF29B84A),
                      ),
                      onPressed: _safe,
                      icon: const Icon(Icons.verified_user),
                      label: const Text(
                        "I'M SAFE",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Your phone will open its call workflow; the operating system controls final call confirmation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF657184)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _state(String title, String value, bool green) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    trailing: Text(
      value,
      style: TextStyle(
        color: green ? const Color(0xFF29B84A) : const Color(0xFFED2B2F),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
  String _masked(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, phone.length.clamp(0, 3))} ••• ••• ${phone.substring(phone.length - 3)}';
  }
}
