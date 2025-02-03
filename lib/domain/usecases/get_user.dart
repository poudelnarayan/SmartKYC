import 'package:smartkyc/domain/entities/user.dart';
import 'package:smartkyc/domain/repository/user_repository_impl.dart';

import '../repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class GetUser {
  final UserRepository userRepository = UserRepositoryImpl();

  Future<User> call(String uid) async {
    return userRepository.getUser(uid);
  }

  String? get userEmail => auth.FirebaseAuth.instance.currentUser?.email;
}
