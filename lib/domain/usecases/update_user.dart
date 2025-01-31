import '../entities/user.dart';
import '../repository/user_repository.dart';
import '../repository/user_repository_impl.dart';

class UpdateUser {
  final UserRepository userRepository = UserRepositoryImpl();

  Future<void> call(User user) async {
    return await userRepository.updateUser(user);
  }

  

  Future<void> verifySelfie(
    String userId,
    String field,
    dynamic value,
  ) async {
    return await userRepository.updateUserSelfieVerification(
        userId, field, value);
  }

  Future<void> verifyLiveness(
    String userId,
    String field,
    dynamic value,
  ) async {
    return await userRepository.updateUserLivenessVerification(
        userId, field, value);
  }
}
