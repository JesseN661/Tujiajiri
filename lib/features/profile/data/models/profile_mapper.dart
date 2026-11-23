import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/user_profile.dart';

/// Converts profile entities to and from Firestore maps (field names here
/// are the ones in the ERD and in firestore.rules).
class ProfileMapper {
  const ProfileMapper._();

  static UserProfile profileFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserProfile(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? '',
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
    );
  }

  static Education educationFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Education(
      id: doc.id,
      school: data['school'] as String? ?? '',
      degree: data['degree'] as String? ?? '',
      fieldOfStudy: data['fieldOfStudy'] as String? ?? '',
      startYear: (data['startYear'] as num?)?.toInt() ?? 0,
      endYear: (data['endYear'] as num?)?.toInt(),
    );
  }

  static Experience experienceFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Experience(
      id: doc.id,
      company: data['company'] as String? ?? '',
      role: data['role'] as String? ?? '',
      startYear: (data['startYear'] as num?)?.toInt() ?? 0,
      endYear: (data['endYear'] as num?)?.toInt(),
      description: data['description'] as String? ?? '',
    );
  }

  /// Timestamps are added by the repository, not here.
  static Map<String, dynamic> profileToMap(UserProfile profile) => {
    'fullName': profile.fullName,
    'email': profile.email,
    'phone': profile.phone,
    'location': profile.location,
    'onboardingComplete': profile.onboardingComplete,
  };

  static Map<String, dynamic> educationToMap(Education item) => {
    'school': item.school,
    'degree': item.degree,
    'fieldOfStudy': item.fieldOfStudy,
    'startYear': item.startYear,
    'endYear': item.endYear,
  };

  static Map<String, dynamic> experienceToMap(Experience item) => {
    'company': item.company,
    'role': item.role,
    'startYear': item.startYear,
    'endYear': item.endYear,
    'description': item.description,
  };
}
