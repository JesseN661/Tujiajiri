import 'package:equatable/equatable.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus { loading, loaded, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.education = const [],
    this.experience = const [],
    this.message,
    this.isError = false,
    this.feedbackId = 0,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final List<Education> education;
  final List<Experience> experience;

  /// One-off text for a snackbar; [feedbackId] makes repeats show.
  final String? message;
  final bool isError;
  final int feedbackId;

  /// Note: [message] is cleared unless you pass it.
  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<Education>? education,
    List<Experience>? experience,
    String? message,
    bool? isError,
    int? feedbackId,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      message: message,
      isError: isError ?? this.isError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    education,
    experience,
    message,
    isError,
    feedbackId,
  ];
}
