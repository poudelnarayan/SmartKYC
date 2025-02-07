import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class IAuthService {
  Stream<User?> get authStateChanges;
  Stream<User?> get idTokenChanges;
  Future<void> signOut();
}

class AuthService implements IAuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out');
    }
  }
}
