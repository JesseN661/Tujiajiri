import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entry_id.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/validators/profile_validators.dart';
import 'profile_state.dart';

/// Live view of the signed-in user's profile, with edit, add and delete.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UserProfileRepository repository, required String uid})
    : _repository = repository,
      _uid = uid,
      super(const ProfileState());

  final UserProfileRepository _repository;
  final String _uid;

  final List<StreamSubscription<Object?>> _subscriptions = [];

  /// Unique id for a new education or experience entry.
  String newId() => newEntryId();

  /// Starts (or restarts) listening to Firestore; the screen updates live.
  void start() {
    _cancelSubscriptions();
    emit(state.copyWith(status: ProfileStatus.loading));
    _subscriptions
      ..add(
        _repository
            .watchProfile(_uid)
            .listen(
              (profile) => _emitIfOpen(
                state.copyWith(status: ProfileStatus.loaded, profile: profile),
              ),
              onError: (Object _) => _fail(),
            ),
      )
      ..add(
        _repository
            .watchEducation(_uid)
            .listen(
              (items) => _emitIfOpen(state.copyWith(education: items)),
              onError: (Object _) => _fail(),
            ),
      )
      ..add(
        _repository
            .watchExperience(_uid)
            .listen(
              (items) => _emitIfOpen(state.copyWith(experience: items)),
              onError: (Object _) => _fail(),
            ),
      );
  }

  Future<void> updatePersonal({
    required String fullName,
    required String phone,
    required String location,
  }) async {
    final current = state.profile;
    final error =
        ProfileValidators.fullName(fullName) ??
        ProfileValidators.phone(phone) ??
        ProfileValidators.location(location);
    if (error != null) return _notify(error, isError: true);
    if (current == null) {
      return _notify('Your profile is still loading.', isError: true);
    }
    await _run(
      () => _repository.updateProfile(
        current.copyWith(
          fullName: fullName.trim(),
          phone: phone.trim(),
          location: location.trim(),
        ),
      ),
      success: 'Personal details updated.',
    );
  }

  Future<void> saveEducation(Education item) => _run(
    () => _repository.saveEducation(_uid, item),
    success: 'Education saved.',
  );

  Future<void> deleteEducation(String id) => _run(
    () => _repository.deleteEducation(_uid, id),
    success: 'Education removed.',
  );

  Future<void> saveExperience(Experience item) => _run(
    () => _repository.saveExperience(_uid, item),
    success: 'Experience saved.',
  );

  Future<void> deleteExperience(String id) => _run(
    () => _repository.deleteExperience(_uid, id),
    success: 'Experience removed.',
  );

  Future<void> _run(
    Future<void> Function() action, {
    required String success,
  }) async {
    try {
      await action();
      _notify(success);
    } catch (_) {
      _notify('Could not save your changes. Please try again.', isError: true);
    }
  }

  void _fail() => _emitIfOpen(
    state.copyWith(
      status: ProfileStatus.failure,
      message: 'Could not load your profile.',
      isError: true,
      feedbackId: state.feedbackId + 1,
    ),
  );

  void _notify(String message, {bool isError = false}) => _emitIfOpen(
    state.copyWith(
      message: message,
      isError: isError,
      feedbackId: state.feedbackId + 1,
    ),
  );

  void _emitIfOpen(ProfileState next) {
    if (!isClosed) emit(next);
  }

  void _cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
