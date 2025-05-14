import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../entities/user.dart';

import '../repository/user_repository.dart';
import '../repository/user_repository_impl.dart';

class GetUser {
  final UserRepository _repository;
  final firebase_auth.FirebaseAuth _auth;

  GetUser({
    UserRepository? repository,
    firebase_auth.FirebaseAuth? auth,
  })  : _repository = repository ?? UserRepositoryImpl(),
        _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  Future<User> call() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    return _repository.getUser(user.uid);
  }

  String? getEmail() {
    return _auth.currentUser?.email;
  }
}
