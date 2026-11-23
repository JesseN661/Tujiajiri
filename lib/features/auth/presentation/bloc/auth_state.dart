import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

/// Where the user is in the sign-in journey; the app gate routes on this.
enum AuthStatus {
  /// Waiting for Firebase to report the saved session (app just started).
  unknown,
  unauthenticated,

  /// Signed in with email/password but has not verified the email yet.
  needsVerification,
  authenticated,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isBusy = false,
    this.message,
    this.isError = false,
    this.feedbackId = 0,
  });

  final AuthStatus status;
  final AppUser? user;

  /// True while a request is running, so buttons can show progress.
  final bool isBusy;

  /// One-off text for a snackbar. [feedbackId] changes every time, so the
  /// same message can be shown twice in a row.
  final String? message;
  final bool isError;
  final int feedbackId;

  /// Note: [message] is cleared unless you pass it (same as applications).
  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    bool? isBusy,
    String? message,
    bool? isError,
    int? feedbackId,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isBusy: isBusy ?? this.isBusy,
      message: message,
      isError: isError ?? this.isError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    isBusy,
    message,
    isError,
    feedbackId,
  ];
}
