import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_failure.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_error_mapper.dart';

/// [AuthRepository] backed by Firebase Auth and Google Sign-In.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  // Google Sign-In v7 must be initialized once before first use.
  bool _googleReady = false;

  AppUser? _toUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      emailVerified: user.emailVerified,
    );
  }

  /// Runs [action] and converts Firebase errors into [AuthFailure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(AuthErrorMapper.messageFor(e.code));
    }
  }

  @override
  Stream<AppUser?> watchUser() => _auth.userChanges().map(_toUser);

  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name);
      // Verification email is the extra security step after sign-up.
      await user.sendEmailVerification();
      return _toUser(_auth.currentUser ?? user)!;
    });
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toUser(credential.user)!;
    });
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      if (!_googleReady) {
        await _google.initialize();
        _googleReady = true;
      }
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure('Google did not return a sign-in token.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      return _toUser(result.user)!;
    } on GoogleSignInException catch (e) {
      throw AuthFailure(
        e.code == GoogleSignInExceptionCode.canceled
            ? 'Google sign-in was cancelled.'
            : 'Google sign-in failed. Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(AuthErrorMapper.messageFor(e.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _guard(() async {
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (e) {
        // Hide whether the account exists; the UI shows a generic message.
        if (e.code != 'user-not-found') rethrow;
      }
    });
  }

  @override
  Future<void> sendEmailVerification() {
    return _guard(() async {
      final user = _auth.currentUser;
      if (user == null) throw const AuthFailure('You are not signed in.');
      await user.sendEmailVerification();
    });
  }

  @override
  Future<AppUser?> reloadUser() {
    return _guard(() async {
      final user = _auth.currentUser;
      if (user == null) return null;
      await user.reload();
      // Refresh the token so security rules see email_verified = true.
      await _auth.currentUser?.getIdToken(true);
      return _toUser(_auth.currentUser);
    });
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      // Also clear Google's chosen account so the picker shows next time.
      if (!_googleReady) {
        await _google.initialize();
        _googleReady = true;
      }
      await _google.signOut();
    } on Object {
      // Best effort: Firebase sign-out above is what ends the session.
    }
  }
}
