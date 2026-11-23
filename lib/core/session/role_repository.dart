import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

/// Reads the signed-in user's role from `users/{uid}`.
class RoleRepository {
  RoleRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Emits the user's role, and again whenever an admin changes it.
  /// A user with no profile document yet is treated as a seeker.
  Stream<UserRole> watchRole(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => UserRole.fromName(doc.data()?['role'] as String?));
}
