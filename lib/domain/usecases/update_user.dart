import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/user.dart';
import '../repository/user_repository.dart';
import '../repository/user_repository_impl.dart';

class UpdateUser {
  final UserRepository userRepository = UserRepositoryImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call(User user) async {
    try {
      // Get existing user data first
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Merge new data with existing data
        final existingData = docSnapshot.data() ?? {};
        final updatedData = {
          ...existingData,
          ...user.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Update with merged data
        await docRef.update(updatedData);
      } else {
        // If document doesn't exist, create it
        await docRef.set({
          ...user.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> verifyDocument(
    String userId,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating document verification: $e');
      throw Exception('Failed to update document verification: $e');
    }
  }

  Future<void> verifySelfie(
    String userId,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating selfie verification: $e');
      throw Exception('Failed to update selfie verification: $e');
    }
  }

  Future<void> verifyLiveness(
    String userId,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating liveness verification: $e');
      throw Exception('Failed to update liveness verification: $e');
    }
  }
}
