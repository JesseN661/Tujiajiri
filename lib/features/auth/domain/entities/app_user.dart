import 'package:equatable/equatable.dart';

/// The signed-in person, independent of any Firebase type.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.emailVerified = false,
  });

  final String uid;
  final String email;
  final String displayName;

  /// False until the user opens the link in the verification email.
  final bool emailVerified;

  @override
  List<Object?> get props => [uid, email, displayName, emailVerified];
}
