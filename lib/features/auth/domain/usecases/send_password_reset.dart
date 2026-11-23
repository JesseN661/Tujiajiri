import '../auth_failure.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

/// Validates the email, then asks Firebase to send a reset link.
class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) async {
    final error = AuthValidators.email(email);
    if (error != null) throw AuthFailure(error);

    return _repository.sendPasswordReset(email.trim());
  }
}
