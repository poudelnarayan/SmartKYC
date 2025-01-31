import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/models/auth_user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserDetails(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Convert dates to Timestamps for Firestore
      final processedData = {
        ...userData,
        'dob': Timestamp.fromDate(userData['dob'] as DateTime),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(
            processedData,
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to update user details: $e');
    }
  }

  Future<AuthUserModel?> getUserDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      // Convert Timestamp back to DateTime
      data['dob'] = (data['dob'] as Timestamp).toDate().toIso8601String();

      return AuthUserModel.fromJson({
        'id': user.uid,
        ...data,
      });
    } catch (e) {
      throw Exception('Failed to get user details: $e');
    }
  }
}
