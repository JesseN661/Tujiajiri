import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile(String uid, Map<String, dynamic> profileData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(profileData, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();

    if (document.exists) {
      return document.data();
    }

    return null;
  }
}
