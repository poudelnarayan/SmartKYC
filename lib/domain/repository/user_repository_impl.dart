import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartkyc/domain/entities/user.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

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
  Future<void> updateUserLivenessVerification(
      String userId, String field, dynamic value) async {
    try {
      await _firestore.collection('users').doc(userId).update({
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
      await _firestore.collection('users').doc(userId).update({
        field: value,
      });
      print("User field updated successfully.");
    } catch (e) {
      print("Failed to update user field: $e");
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      // Get reference to user document
      final userRef = _firestore.collection('users').doc(uid);

      // Get user data to find associated files
      final userData = await userRef.get();

      if (userData.exists) {
        // Delete user's files from Storage if they exist
        final userStoragePath = 'users/$uid';

        try {
          // List all files in user's storage directory
          final ListResult result =
              await _storage.ref(userStoragePath).listAll();

          // Delete each file
          for (var item in result.items) {
            await item.delete();
          }

          // Delete all subdirectories
          for (var prefix in result.prefixes) {
            final subDirContents = await prefix.listAll();
            for (var item in subDirContents.items) {
              await item.delete();
            }
          }
        } catch (e) {
          print('Error deleting user files: $e');
          // Continue with user document deletion even if file deletion fails
        }

        // Delete the user document from Firestore
        await userRef.delete();

        print('User $uid successfully deleted');
      } else {
        print('User $uid not found');
      }
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }
}
