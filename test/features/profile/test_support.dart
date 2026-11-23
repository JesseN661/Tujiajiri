import 'dart:async';

import 'package:tujiajiri/features/auth/domain/entities/app_user.dart';
import 'package:tujiajiri/features/profile/domain/entities/education.dart';
import 'package:tujiajiri/features/profile/domain/entities/experience.dart';
import 'package:tujiajiri/features/profile/domain/entities/user_profile.dart';
import 'package:tujiajiri/features/profile/domain/repositories/user_profile_repository.dart';

const testUser = AppUser(
  uid: 'u1',
  email: 'amina@example.com',
  displayName: 'Amina Uwase',
  emailVerified: true,
);

const sampleEducation = Education(
  id: 'e1',
  school: 'IPRC Kigali',
  degree: 'Diploma',
  startYear: 2019,
  endYear: 2022,
);

const sampleExperience = Experience(
  id: 'x1',
  company: 'Shop Ltd',
  role: 'Sales assistant',
  startYear: 2023,
);

/// In-memory [UserProfileRepository] that records what was saved and
/// pushes live updates to watchers.
class FakeProfileRepository implements UserProfileRepository {
  FakeProfileRepository({this.existing});

  /// Returned by [getProfile]; null simulates a brand new user.
  UserProfile? existing;

  /// When true, every call throws, like a Firestore permission error.
  bool failing = false;

  UserProfile? savedProfile;
  List<Education> savedEducation = [];
  List<Experience> savedExperience = [];

  final StreamController<void> _changes = StreamController<void>.broadcast();

  UserProfile? get _profile => savedProfile ?? existing;

  void _guard() {
    if (failing) throw Exception('permission-denied');
  }

  /// Emits the current value, then again after every change.
  Stream<T> _watch<T>(T Function() read) async* {
    _guard();
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    _guard();
    return existing;
  }

  @override
  Future<void> saveOnboarding({
    required UserProfile profile,
    required List<Education> education,
    required List<Experience> experience,
  }) async {
    _guard();
    savedProfile = profile;
    savedEducation = education;
    savedExperience = experience;
    _changes.add(null);
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) => _watch(() => _profile);

  @override
  Stream<List<Education>> watchEducation(String uid) =>
      _watch(() => List.of(savedEducation));

  @override
  Stream<List<Experience>> watchExperience(String uid) =>
      _watch(() => List.of(savedExperience));

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _guard();
    savedProfile = profile;
    _changes.add(null);
  }

  @override
  Future<void> saveEducation(String uid, Education item) async {
    _guard();
    savedEducation = [
      for (final e in savedEducation)
        if (e.id != item.id) e,
      item,
    ];
    _changes.add(null);
  }

  @override
  Future<void> deleteEducation(String uid, String id) async {
    _guard();
    savedEducation = savedEducation.where((e) => e.id != id).toList();
    _changes.add(null);
  }

  @override
  Future<void> saveExperience(String uid, Experience item) async {
    _guard();
    savedExperience = [
      for (final e in savedExperience)
        if (e.id != item.id) e,
      item,
    ];
    _changes.add(null);
  }

  @override
  Future<void> deleteExperience(String uid, String id) async {
    _guard();
    savedExperience = savedExperience.where((e) => e.id != id).toList();
    _changes.add(null);
  }
}
