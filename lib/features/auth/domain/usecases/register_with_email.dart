import '../auth_failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

/// Validates the sign-up form, then creates the account.
class RegisterWithEmail {
  const RegisterWithEmail(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String name,
    required String email,
    required String password,
    required String confirmation,
  }) async {
    // First problem found is reported, so the user fixes one thing at a time.
    final error =
        AuthValidators.name(name) ??
        AuthValidators.email(email) ??
        AuthValidators.newPassword(password) ??
        AuthValidators.confirmPassword(password, confirmation);
    if (error != null) throw AuthFailure(error);

    return _repository.registerWithEmail(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
  }
}
