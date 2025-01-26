import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthUser> call(String email, String password) {
    return repository.signUpWithEmailAndPassword(email, password);
  }
}