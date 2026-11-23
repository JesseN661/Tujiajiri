import '../entities/app_user.dart';

/// Contract for authentication; the data layer implements it with Firebase.
abstract class AuthRepository {
  /// Emits the current user (or null) now and on every sign-in, sign-out
  /// or profile change. This is how the session survives an app restart.
  Stream<AppUser?> watchUser();

  /// Creates the account, sets the display name and sends the verify email.
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> sendEmailVerification();

  /// Re-reads the user from the server (used after they verify their email).
  Future<AppUser?> reloadUser();

  Future<void> signOut();
}
