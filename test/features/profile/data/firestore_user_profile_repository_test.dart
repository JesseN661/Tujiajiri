import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/profile/data/firestore_user_profile_repository.dart';
import 'package:tujiajiri/features/profile/domain/entities/education.dart';
import 'package:tujiajiri/features/profile/domain/entities/experience.dart';
import 'package:tujiajiri/features/profile/domain/entities/user_profile.dart';

const _profile = UserProfile(
  uid: 'u1',
  fullName: 'Amina Uwase',
  email: 'amina@example.com',
  phone: '+250788123456',
  location: 'Kigali',
);

const _education = Education(
  id: 'e1',
  school: 'IPRC Kigali',
  degree: 'Diploma',
  fieldOfStudy: 'ICT',
  startYear: 2019,
  endYear: 2022,
);

const _experience = Experience(
  id: 'x1',
  company: 'Shop Ltd',
  role: 'Sales assistant',
  startYear: 2023,
  description: 'Served customers.',
);

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreUserProfileRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreUserProfileRepository(firestore: firestore);
  });

  test('getProfile returns null when there is no document', () async {
    expect(await repository.getProfile('u1'), isNull);
  });

  test('saveOnboarding writes the user document with the uid as id', () async {
    await repository.saveOnboarding(
      profile: _profile,
      education: const [],
      experience: const [],
    );

    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.exists, isTrue);
    expect(doc.data()?['fullName'], 'Amina Uwase');
    expect(doc.data()?['email'], 'amina@example.com');
    expect(doc.data()?['onboardingComplete'], isTrue);
    expect(doc.data()?['createdAt'], isNotNull);
    expect(doc.data()?['updatedAt'], isNotNull);
  });

  test(
    'saveOnboarding writes education and experience subcollections',
    () async {
      await repository.saveOnboarding(
        profile: _profile,
        education: const [_education],
        experience: const [_experience],
      );

      final user = firestore.collection('users').doc('u1');
      final school = await user.collection('education').doc('e1').get();
      final job = await user.collection('experience').doc('x1').get();

      expect(school.data()?['school'], 'IPRC Kigali');
      expect(school.data()?['endYear'], 2022);
      expect(job.data()?['company'], 'Shop Ltd');
      expect(job.data()?['endYear'], isNull);
    },
  );

  test('getProfile reads back what was saved', () async {
    await repository.saveOnboarding(
      profile: _profile,
      education: const [],
      experience: const [],
    );

    final loaded = await repository.getProfile('u1');

    expect(loaded, _profile.copyWith(onboardingComplete: true));
  });

  test('saving again keeps the original createdAt', () async {
    await repository.saveOnboarding(
      profile: _profile,
      education: const [],
      experience: const [],
    );
    final first = (await firestore.collection('users').doc('u1').get())
        .data()?['createdAt'];

    await repository.saveOnboarding(
      profile: _profile.copyWith(location: 'Huye'),
      education: const [],
      experience: const [],
    );
    final doc = await firestore.collection('users').doc('u1').get();

    expect(doc.data()?['createdAt'], first);
    expect(doc.data()?['location'], 'Huye');
  });
}
