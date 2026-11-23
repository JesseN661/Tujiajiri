import 'package:equatable/equatable.dart';

/// Personal details saved in `users/{uid}`; the document id is the auth uid.
class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.location = '',
    this.onboardingComplete = false,
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String location;

  /// False until the user finishes the onboarding steps.
  final bool onboardingComplete;

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? location,
    bool? onboardingComplete,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    phone,
    location,
    onboardingComplete,
  ];
}
