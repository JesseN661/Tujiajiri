import 'package:equatable/equatable.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';

enum OnboardingStatus {
  /// Checking Firestore for an existing, finished profile.
  loading,
  loadFailed,

  /// The user is filling in the steps.
  inProgress,

  /// Profile is complete; the app can show the main screen.
  ready,
}

/// The three onboarding steps, in order.
enum OnboardingStep { personal, education, experience }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.loading,
    this.step = OnboardingStep.personal,
    this.fullName = '',
    this.phone = '',
    this.location = '',
    this.education = const [],
    this.experience = const [],
    this.isSaving = false,
    this.message,
    this.feedbackId = 0,
  });

  final OnboardingStatus status;
  final OnboardingStep step;
  final String fullName;
  final String phone;
  final String location;
  final List<Education> education;
  final List<Experience> experience;
  final bool isSaving;

  /// One-off error text for a snackbar; [feedbackId] makes repeats show.
  final String? message;
  final int feedbackId;

  /// Note: [message] is cleared unless you pass it.
  OnboardingState copyWith({
    OnboardingStatus? status,
    OnboardingStep? step,
    String? fullName,
    String? phone,
    String? location,
    List<Education>? education,
    List<Experience>? experience,
    bool? isSaving,
    String? message,
    int? feedbackId,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      step: step ?? this.step,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      isSaving: isSaving ?? this.isSaving,
      message: message,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    step,
    fullName,
    phone,
    location,
    education,
    experience,
    isSaving,
    message,
    feedbackId,
  ];
}
