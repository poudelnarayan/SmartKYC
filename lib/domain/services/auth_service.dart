import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class IAuthService {
  void initAuthStateListener(BuildContext context);
  Future<void> signOut();
}

class AuthService implements IAuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  void initAuthStateListener(BuildContext context) {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _handleSignOut(context);
      }
    });

    _auth.idTokenChanges().listen((User? user) async {
      if (user != null) {
        try {
          await user.getIdToken(true);
        } catch (e) {
          await signOut();
          if (context.mounted) {
            _handleSignOut(context);
          }
        }
      }
    });
  }

  void _handleSignOut(BuildContext context) {
    // Navigate to sign in page
    context.go('/auth');

    // Show session expired message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please sign in again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

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
