import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartkyc/domain/entities/user.dart';

import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromJson(doc.data()!);
    } else {
      throw Exception("User not found");
    }
  }

  @override
  Future<void> updateUser(User user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> updateUserDocumentVerification(
      String userId, String field, dynamic value) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        field: value,
      });
      print("User field updated successfully.");
    } catch (e) {
      print("Failed to update user field: $e");
    }
  }

  @override
  Future<void> updateUserLivenessVerification(
      String userId, String field, dynamic value) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        field: value,
      });
      print("User field updated successfully.");
    } catch (e) {
      print("Failed to update user field: $e");
    }
  }

  @override
  Future<void> updateUserSelfieVerification(
      String userId, String field, dynamic value) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        field: value,
      });
      print("User field updated successfully.");
    } catch (e) {
      print("Failed to update user field: $e");
    }
  }
}
