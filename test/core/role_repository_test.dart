import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/core/session/role_repository.dart';
import 'package:tujiajiri/core/session/user_role.dart';

void main() {
  group('UserRole.fromName', () {
    test('reads known roles', () {
      expect(UserRole.fromName('employer'), UserRole.employer);
      expect(UserRole.fromName('admin'), UserRole.admin);
      expect(UserRole.fromName('seeker'), UserRole.seeker);
    });

    test('treats missing or unknown roles as seeker', () {
      expect(UserRole.fromName(null), UserRole.seeker);
      expect(UserRole.fromName('superuser'), UserRole.seeker);
    });

    test('only employers and admins review applications', () {
      expect(UserRole.seeker.reviewsApplications, isFalse);
      expect(UserRole.employer.reviewsApplications, isTrue);
      expect(UserRole.admin.reviewsApplications, isTrue);
    });
  });

  group('RoleRepository', () {
    late FakeFirebaseFirestore firestore;
    late RoleRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = RoleRepository(firestore);
    });

    test('a user without a profile is a seeker', () async {
      expect(await repository.watchRole('new-user').first, UserRole.seeker);
    });

    test('reads the role from users/{uid}', () async {
      await firestore.collection('users').doc('u1').set({'role': 'employer'});
      expect(await repository.watchRole('u1').first, UserRole.employer);
    });

    test('emits again when the role changes', () async {
      final users = firestore.collection('users');
      await users.doc('u2').set({'role': 'seeker'});

      final roles = repository.watchRole('u2');
      final expectation = expectLater(
        roles,
        emitsInOrder([UserRole.seeker, UserRole.admin]),
      );
      await users.doc('u2').update({'role': 'admin'});
      await expectation;
    });
  });
}
