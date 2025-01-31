class User {
  final String uid;
  final String licenseNumber;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String fatherName;
  final String citizenshipNumber;
  final String? phoneNumber;

  // High-level verification flags (for global access control)
  final bool isDocumentVerified;
  final bool isSelfieVerified;
  final bool isLivenessVerified;

  User({
    required this.uid,
    required this.licenseNumber,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.fatherName,
    required this.citizenshipNumber,
    this.phoneNumber,
    this.isDocumentVerified = false,
    this.isSelfieVerified = false,
    this.isLivenessVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'licenseNumber': licenseNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob.toIso8601String(),
      'fatherName': fatherName,
      'citizenshipNumber': citizenshipNumber,
      'phoneNumber': phoneNumber,
      'isDocumentVerified': isDocumentVerified,
      'isSelfieVerified': isSelfieVerified,
      'isLivenessVerified': isLivenessVerified,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      licenseNumber: json['licenseNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: DateTime.parse(json['dob']),
      fatherName: json['fatherName'],
      citizenshipNumber: json['citizenshipNumber'],
      phoneNumber: json['phoneNumber'],
      isDocumentVerified: json['isDocumentVerified'] ?? false,
      isSelfieVerified: json['isSelfieVerified'] ?? false,
      isLivenessVerified: json['isLivenessVerified'] ?? false,
    );
  }
}
