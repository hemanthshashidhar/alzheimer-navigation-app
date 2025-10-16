class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType; // 'patient' or 'caregiver'
  final String? profileImage;
  final List<EmergencyContact> emergencyContacts;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    this.emergencyContacts = const [],
  });
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });
}