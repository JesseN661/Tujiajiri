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
}
