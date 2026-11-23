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
    this.skills = const [],
    this.interests = const [],
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String location;

  /// False until the user finishes the onboarding steps.
  final bool onboardingComplete;

  final List<String> skills;
  final List<String> interests;

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? location,
    bool? onboardingComplete,
    List<String>? skills,
    List<String>? interests,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
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
    skills,
    interests,
  ];
}
