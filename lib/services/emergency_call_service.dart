import 'package:url_launcher/url_launcher.dart';

class EmergencyCallService {
  const EmergencyCallService();

  static const String emergencyServicesNumber = String.fromEnvironment(
    'EMERGENCY_SERVICES_NUMBER',
    defaultValue: '',
  );

  Future<bool> openDialer(String phone) async {
    final normalized = phone.trim();
    if (normalized.isEmpty) return false;
    return launchUrl(Uri(scheme: 'tel', path: normalized));
  }
}
