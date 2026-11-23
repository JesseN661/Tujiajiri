import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/user_profile_repository.dart';
import 'skills_state.dart';

/// Loads and saves the user's skills and interests in `users/{uid}`.
class SkillsCubit extends Cubit<SkillsState> {
  SkillsCubit({required this._repository, required this._uid})
    : super(const SkillsState());

  final UserProfileRepository _repository;
  final String _uid;

  Future<void> load() async {
    try {
      final profile = await _repository.getProfile(_uid);
      emit(
        SkillsState(
          isLoading: false,
          skills: profile?.skills ?? const [],
          interests: profile?.interests ?? const [],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(isLoading: false, error: 'Could not load your skills.'),
      );
    }
  }

  Future<void> addSkill(String value) =>
      _save(skills: _added(state.skills, value));

  Future<void> removeSkill(String value) =>
      _save(skills: state.skills.where((s) => s != value).toList());

  Future<void> addInterest(String value) =>
      _save(interests: _added(state.interests, value));

  Future<void> removeInterest(String value) =>
      _save(interests: state.interests.where((i) => i != value).toList());

  List<String> _added(List<String> list, String value) {
    final text = value.trim();
    final exists = list.any((item) => item.toLowerCase() == text.toLowerCase());
    if (text.isEmpty || exists) return list;
    return [...list, text];
  }

  Future<void> _save({List<String>? skills, List<String>? interests}) async {
    final before = state;
    final next = state.copyWith(skills: skills, interests: interests);
    if (next == before) return;

    emit(next);
    try {
      await _repository.saveSkills(
        _uid,
        skills: next.skills,
        interests: next.interests,
      );
    } catch (_) {
      emit(before.copyWith(error: 'Could not save. Please try again.'));
    }
  }
}
