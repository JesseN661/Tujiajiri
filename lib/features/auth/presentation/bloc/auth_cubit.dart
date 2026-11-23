import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import 'auth_state.dart';

/// Owns the session: reacts to Firebase, and runs every auth action.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository})
    : _repository = repository,
      _register = RegisterWithEmail(repository),
      _signIn = SignInWithEmail(repository),
      _sendReset = SendPasswordReset(repository),
      super(const AuthState()) {
    // Firebase restores a saved session here, so login survives a restart.
    _subscription = _repository.watchUser().listen(
      _onUserChanged,
      onError: (Object _) => _onUserChanged(null),
    );
  }

  final AuthRepository _repository;
  final RegisterWithEmail _register;
  final SignInWithEmail _signIn;
  final SendPasswordReset _sendReset;

  late final StreamSubscription<AppUser?> _subscription;

  static const _resetSentMessage =
      'If an account exists for that email, a reset link has been sent.';

  void _onUserChanged(AppUser? user) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: _statusFor(user),
        user: user,
        clearUser: user == null,
      ),
    );
  }

  AuthStatus _statusFor(AppUser? user) {
    if (user == null) return AuthStatus.unauthenticated;
    return user.emailVerified
        ? AuthStatus.authenticated
        : AuthStatus.needsVerification;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmation,
  }) => _run(
    () => _register(
      name: name,
      email: email,
      password: password,
      confirmation: confirmation,
    ),
    success: 'Account created. Check your email to verify it.',
  );

  Future<void> signIn({required String email, required String password}) =>
      _run(() => _signIn(email: email, password: password));

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  /// Returns true when the request was sent, so the page can close itself.
  Future<bool> sendPasswordReset(String email) =>
      _run(() => _sendReset(email), success: _resetSentMessage);

  Future<void> resendVerificationEmail() => _run(
    _repository.sendEmailVerification,
    success: 'Verification email sent. Check your inbox.',
  );

  /// Called when the user says they verified; re-reads the account state.
  Future<void> refreshVerification() async {
    AppUser? refreshed;
    final ok = await _run(
      () async => refreshed = await _repository.reloadUser(),
    );
    if (!ok || isClosed) return;

    // Apply the fresh user right away instead of waiting for the stream.
    final user = refreshed;
    _onUserChanged(user);
    if (user != null && !user.emailVerified) {
      _notify('Your email is not verified yet. Open the link we sent.', true);
    }
  }

  Future<void> signOut() => _run(_repository.signOut);

  /// Runs [action] with busy/error handling; returns whether it succeeded.
  Future<bool> _run(
    Future<Object?> Function() action, {
    String? success,
  }) async {
    emit(state.copyWith(isBusy: true));
    try {
      await action();
      if (isClosed) return true;
      emit(state.copyWith(isBusy: false));
      if (success != null) _notify(success, false);
      return true;
    } on AuthFailure catch (e) {
      _finishWithError(e.message);
    } catch (_) {
      _finishWithError('Something went wrong. Please try again.');
    }
    return false;
  }

  void _finishWithError(String message) {
    if (isClosed) return;
    emit(state.copyWith(isBusy: false));
    _notify(message, true);
  }

  void _notify(String message, bool isError) {
    if (isClosed) return;
    emit(
      state.copyWith(
        message: message,
        isError: isError,
        feedbackId: state.feedbackId + 1,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
