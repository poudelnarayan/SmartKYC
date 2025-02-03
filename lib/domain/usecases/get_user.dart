import 'package:smartkyc/domain/entities/user.dart';
import 'package:smartkyc/domain/repository/user_repository_impl.dart';

import '../repository/user_repository.dart';

class GetUser {
  final UserRepository userRepository = UserRepositoryImpl();

  Future<User> call(String uid) async {
    return userRepository.getUser(uid);
  }
}
