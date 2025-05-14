import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DeleteUser {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> call() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final uid = user.uid;

      // 1. Delete user data from Firestore
      await _deleteUserData(uid);

      // 2. Delete user files from Storage
      await _deleteUserFiles(uid);

      // 3. Delete Firebase Auth account
      await user.delete();

      // 4. Sign out after successful deletion
      await _auth.signOut();
    } catch (e) {
      print('Error in DeleteUser: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print('Error deleting user data: $e');
      throw Exception('Failed to delete user data: $e');
    }
  }

  Future<void> _deleteUserFiles(String uid) async {
    try {
      final storageRef = _storage.ref().child('users/$uid');

      // List all files in user's directory
      final ListResult result = await storageRef.listAll();

      // Delete all files
      await Future.wait([
        ...result.items.map((ref) => ref.delete()),
        ...result.prefixes.map((ref) => _deleteFolder(ref))
      ]);
    } catch (e) {
      print('Error deleting user files: $e');
      throw Exception('Failed to delete user files: $e');
    }
  }

  Future<void> _deleteFolder(Reference folderRef) async {
    try {
      final ListResult result = await folderRef.listAll();
      await Future.wait([
        ...result.items.map((ref) => ref.delete()),
        ...result.prefixes.map((ref) => _deleteFolder(ref))
      ]);
    } catch (e) {
      print('Error deleting folder: $e');
      throw Exception('Failed to delete folder: $e');
    }
  }
}
