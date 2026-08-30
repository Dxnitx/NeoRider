import '../models/emergency_contact.dart';

class EmergencyContactService {
  const EmergencyContactService();

  // TODO: Replace fallback contact with user-saved emergency contact.
  Future<EmergencyContact> primaryContact() async =>
      const EmergencyContact(name: 'Emergency Contact', phone: '+94770000245');
}
