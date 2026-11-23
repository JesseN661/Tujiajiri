import '../auth_failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

/// Validates the login form, then signs in.
class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String email,
    required String password,
  }) async {
    final error =
        AuthValidators.email(email) ?? AuthValidators.loginPassword(password);
    if (error != null) throw AuthFailure(error);

    return _repository.signInWithEmail(email: email.trim(), password: password);
  }
}
