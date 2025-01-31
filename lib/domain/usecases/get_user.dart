import 'package:smartkyc/domain/entities/user.dart';

import '../repository/user_repository.dart';

class GetUser {
  final UserRepository repository;

  GetUser(this.repository);

  Future<User> call(String uid) async {
    return repository.getUser(uid);
  }
}
