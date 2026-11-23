import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entry_id.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/validators/profile_validators.dart';
import 'onboarding_state.dart';

/// Loads the profile, runs the three onboarding steps and saves the result.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required UserProfileRepository repository,
    required AppUser user,
  }) : _repository = repository,
       _user = user,
       super(const OnboardingState());

  final UserProfileRepository _repository;
  final AppUser _user;

  /// Unique id for a new education or experience entry (becomes a doc id).
  String newId() => newEntryId();

  /// Checks Firestore: a finished profile skips onboarding on every launch.
  Future<void> load() async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final profile = await _repository.getProfile(_user.uid);
      if (isClosed) return;
      if (profile?.onboardingComplete ?? false) {
        emit(state.copyWith(status: OnboardingStatus.ready));
        return;
      }
      // Prefill from the account so the user types less.
      emit(
        state.copyWith(
          status: OnboardingStatus.inProgress,
          fullName: profile?.fullName ?? _user.displayName,
          phone: profile?.phone ?? '',
          location: profile?.location ?? '',
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(status: OnboardingStatus.loadFailed));
    }
  }

  /// Validates step 1 and moves to step 2.
  void submitPersonal({
    required String fullName,
    required String phone,
    required String location,
  }) {
    final error =
        ProfileValidators.fullName(fullName) ??
        ProfileValidators.phone(phone) ??
        ProfileValidators.location(location);
    if (error != null) {
      _notify(error);
      return;
    }
    emit(
      state.copyWith(
        fullName: fullName.trim(),
        phone: phone.trim(),
        location: location.trim(),
        step: OnboardingStep.education,
      ),
    );
  }

  void goToStep(OnboardingStep step) => emit(state.copyWith(step: step));

  /// Adds the entry, or replaces the one with the same id (edit).
  void saveEducation(Education item) {
    final items = [...state.education];
    final index = items.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    emit(state.copyWith(education: items));
  }

  void removeEducation(String id) => emit(
    state.copyWith(
      education: state.education.where((e) => e.id != id).toList(),
    ),
  );

  void saveExperience(Experience item) {
    final items = [...state.experience];
    final index = items.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    emit(state.copyWith(experience: items));
  }

  void removeExperience(String id) => emit(
    state.copyWith(
      experience: state.experience.where((e) => e.id != id).toList(),
    ),
  );

  /// Saves everything to Firestore and finishes onboarding.
  Future<void> finish() async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _repository.saveOnboarding(
        profile: UserProfile(
          uid: _user.uid,
          fullName: state.fullName,
          email: _user.email,
          phone: state.phone,
          location: state.location,
        ),
        education: state.education,
        experience: state.experience,
      );
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, status: OnboardingStatus.ready));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false));
      _notify('Could not save your profile. Check your connection and retry.');
    }
  }

  void _notify(String message) {
    emit(state.copyWith(message: message, feedbackId: state.feedbackId + 1));
  }
}
