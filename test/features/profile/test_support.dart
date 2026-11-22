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

/// In-memory [UserProfileRepository] that records what was saved.
class FakeProfileRepository implements UserProfileRepository {
  FakeProfileRepository({this.existing});

  /// Returned by [getProfile]; null simulates a brand new user.
  UserProfile? existing;

  /// When true, every call throws, like a Firestore permission error.
  bool failing = false;

  UserProfile? savedProfile;
  List<Education> savedEducation = [];
  List<Experience> savedExperience = [];

  @override
  Future<UserProfile?> getProfile(String uid) async {
    if (failing) throw Exception('permission-denied');
    return existing;
  }

  @override
  Future<void> saveOnboarding({
    required UserProfile profile,
    required List<Education> education,
    required List<Experience> experience,
  }) async {
    if (failing) throw Exception('unavailable');
    savedProfile = profile;
    savedEducation = education;
    savedExperience = experience;
  }
}
