import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/education.dart';
import '../domain/entities/experience.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/user_profile_repository.dart';
import 'models/profile_mapper.dart';

/// Stores profiles in Firestore:
/// `users/{uid}`, `users/{uid}/education/{id}`, `users/{uid}/experience/{id}`.
class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return ProfileMapper.profileFromDoc(doc);
  }

  @override
  Future<void> saveOnboarding({
    required UserProfile profile,
    required List<Education> education,
    required List<Experience> experience,
  }) async {
    final userDoc = _userDoc(profile.uid);
    final existing = await userDoc.get();

    // One batch: either everything is saved or nothing is.
    final batch = _firestore.batch();
    batch.set(userDoc, {
      ...ProfileMapper.profileToMap(profile.copyWith(onboardingComplete: true)),
      // Keep the original creation time if the document already exists.
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    for (final item in education) {
      batch.set(
        userDoc.collection('education').doc(item.id),
        ProfileMapper.educationToMap(item),
      );
    }
    for (final item in experience) {
      batch.set(
        userDoc.collection('experience').doc(item.id),
        ProfileMapper.experienceToMap(item),
      );
    }
    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> _education(String uid) =>
      _userDoc(uid).collection('education');

  CollectionReference<Map<String, dynamic>> _experience(String uid) =>
      _userDoc(uid).collection('experience');

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      _userDoc(uid)
          .snapshots()
          .map((doc) => doc.exists ? ProfileMapper.profileFromDoc(doc) : null);

  // Newest first, sorted on the device so no composite index is needed.
  @override
  Stream<List<Education>> watchEducation(String uid) =>
      _education(uid).snapshots().map(
        (snapshot) =>
            snapshot.docs.map(ProfileMapper.educationFromDoc).toList()
              ..sort((a, b) => b.startYear.compareTo(a.startYear)),
      );

  @override
  Stream<List<Experience>> watchExperience(String uid) =>
      _experience(uid).snapshots().map(
        (snapshot) =>
            snapshot.docs.map(ProfileMapper.experienceFromDoc).toList()
              ..sort((a, b) => b.startYear.compareTo(a.startYear)),
      );

  @override
  Future<void> updateProfile(UserProfile profile) => _userDoc(profile.uid).set({
    // Only editable fields: never touches email or onboardingComplete.
    'fullName': profile.fullName,
    'phone': profile.phone,
    'location': profile.location,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  @override
  Future<void> saveEducation(String uid, Education item) =>
      _education(uid).doc(item.id).set(ProfileMapper.educationToMap(item));

  @override
  Future<void> deleteEducation(String uid, String id) =>
      _education(uid).doc(id).delete();

  @override
  Future<void> saveExperience(String uid, Experience item) =>
      _experience(uid).doc(item.id).set(ProfileMapper.experienceToMap(item));

  @override
  Future<void> deleteExperience(String uid, String id) =>
      _experience(uid).doc(id).delete();
}
