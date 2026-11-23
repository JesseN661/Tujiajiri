import '../entities/education.dart';
import '../entities/experience.dart';
import '../entities/user_profile.dart';

/// Contract for reading and saving a user's profile.
abstract class UserProfileRepository {
  /// Returns null when the user has no profile document yet.
  Future<UserProfile?> getProfile(String uid);

  /// Saves the profile and its education and experience in one atomic write,
  /// and marks onboarding as complete.
  Future<void> saveOnboarding({
    required UserProfile profile,
    required List<Education> education,
    required List<Experience> experience,
  });

  /// Live updates, so the screen changes as soon as a write happens.
  Stream<UserProfile?> watchProfile(String uid);
  Stream<List<Education>> watchEducation(String uid);
  Stream<List<Experience>> watchExperience(String uid);

  /// Updates the personal details of an existing profile.
  Future<void> updateProfile(UserProfile profile);

  Future<void> saveSkills(
    String uid, {
    required List<String> skills,
    required List<String> interests,
  });

  /// Adds the entry, or replaces the one with the same id.
  Future<void> saveEducation(String uid, Education item);
  Future<void> deleteEducation(String uid, String id);
  Future<void> saveExperience(String uid, Experience item);
  Future<void> deleteExperience(String uid, String id);
}
