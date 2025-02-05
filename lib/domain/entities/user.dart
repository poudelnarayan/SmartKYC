import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String email;
  final String licenseNumber;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String fatherName;
  final String citizenshipNumber;
  final String phoneNumber;
  final String address;
  final bool isEmailVerified;
  final bool isDocumentVerified;
  final bool isSelfieVerified;
  final bool isLivenessVerified;

  const User({
    required this.uid,
    required this.email,
    required this.licenseNumber,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.fatherName,
    required this.citizenshipNumber,
    this.phoneNumber = '', // Default value
    this.address = '', // Default value
    this.isEmailVerified = false,
    this.isDocumentVerified = false,
    this.isSelfieVerified = false,
    this.isLivenessVerified = false,
  });

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [
        uid,
        email,
        licenseNumber,
        firstName,
        lastName,
        dob,
        fatherName,
        citizenshipNumber,
        phoneNumber,
        address,
        isEmailVerified,
        isDocumentVerified,
        isSelfieVerified,
        isLivenessVerified,
      ];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'licenseNumber': licenseNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob.toIso8601String(),
      'fatherName': fatherName,
      'citizenshipNumber': citizenshipNumber,
      'phoneNumber': phoneNumber,
      'address': address,
      'isEmailVerified': isEmailVerified,
      'isDocumentVerified': isDocumentVerified,
      'isSelfieVerified': isSelfieVerified,
      'isLivenessVerified': isLivenessVerified,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      licenseNumber: json['licenseNumber'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dob: DateTime.parse(json['dob'] as String),
      fatherName: json['fatherName'] as String,
      citizenshipNumber: json['citizenshipNumber'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isDocumentVerified: json['isDocumentVerified'] as bool? ?? false,
      isSelfieVerified: json['isSelfieVerified'] as bool? ?? false,
      isLivenessVerified: json['isLivenessVerified'] as bool? ?? false,
    );
  }

  User copyWith({
    String? uid,
    String? email,
    String? licenseNumber,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? fatherName,
    String? citizenshipNumber,
    String? phoneNumber,
    String? address,
    bool? isEmailVerified,
    bool? isDocumentVerified,
    bool? isSelfieVerified,
    bool? isLivenessVerified,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      fatherName: fatherName ?? this.fatherName,
      citizenshipNumber: citizenshipNumber ?? this.citizenshipNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isDocumentVerified: isDocumentVerified ?? this.isDocumentVerified,
      isSelfieVerified: isSelfieVerified ?? this.isSelfieVerified,
      isLivenessVerified: isLivenessVerified ?? this.isLivenessVerified,
    );
  }
}
