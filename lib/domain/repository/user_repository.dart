import 'package:smartkyc/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(String uid);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String uid);

  Future<void> updateUserSelfieVerification(
    String userId,
    String field,
    dynamic value,
  );
  Future<void> updateUserLivenessVerification(
    String userId,
    String field,
    dynamic value,
  );
}
