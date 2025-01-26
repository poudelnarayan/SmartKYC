import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<AuthUser> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}