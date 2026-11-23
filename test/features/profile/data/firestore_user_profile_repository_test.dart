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

  test('saveSkills stores skills and interests on the user', () async {
    await repository.saveOnboarding(
      profile: _profile,
      education: const [],
      experience: const [],
    );
    await repository.saveSkills(
      'u1',
      skills: ['Excel', 'Kinyarwanda'],
      interests: ['Sales'],
    );

    final profile = await repository.getProfile('u1');
    expect(profile?.skills, ['Excel', 'Kinyarwanda']);
    expect(profile?.interests, ['Sales']);
    expect(profile?.fullName, 'Amina Uwase');
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

  group('after onboarding', () {
    Future<void> seed() => repository.saveOnboarding(
      profile: _profile,
      education: const [_education],
      experience: const [_experience],
    );

    test('watchProfile and watchEducation stream the saved data', () async {
      await seed();

      expect(
        await repository.watchProfile('u1').first,
        _profile.copyWith(onboardingComplete: true),
      );
      expect(await repository.watchEducation('u1').first, [_education]);
      expect(await repository.watchExperience('u1').first, [_experience]);
    });

    test('updateProfile changes personal details only', () async {
      await seed();

      await repository.updateProfile(
        _profile.copyWith(phone: '0788000111', location: 'Huye'),
      );

      final doc = await firestore.collection('users').doc('u1').get();
      expect(doc.data()?['phone'], '0788000111');
      expect(doc.data()?['location'], 'Huye');
      expect(doc.data()?['email'], 'amina@example.com');
      expect(doc.data()?['onboardingComplete'], isTrue);
    });

    test('saveEducation adds and edits an entry', () async {
      await seed();
      const extra = Education(
        id: 'e2',
        school: 'Uni',
        degree: 'Degree',
        startYear: 2023,
      );

      await repository.saveEducation('u1', extra);
      await repository.saveEducation(
        'u1',
        const Education(
          id: 'e2',
          school: 'University of Rwanda',
          degree: 'Degree',
          startYear: 2023,
        ),
      );

      final items = await repository.watchEducation('u1').first;
      expect(items.map((e) => e.id), ['e2', 'e1']);
      expect(items.first.school, 'University of Rwanda');
      expect(items.first.endYear, isNull);
    });

    test('deleteEducation and deleteExperience remove the entries', () async {
      await seed();

      await repository.deleteEducation('u1', 'e1');
      await repository.deleteExperience('u1', 'x1');

      expect(await repository.watchEducation('u1').first, isEmpty);
      expect(await repository.watchExperience('u1').first, isEmpty);
    });

    test('saveExperience adds an entry', () async {
      await seed();

      await repository.saveExperience(
        'u1',
        const Experience(
          id: 'x2',
          company: 'Cafe',
          role: 'Waiter',
          startYear: 2024,
          endYear: 2025,
        ),
      );

      final items = await repository.watchExperience('u1').first;
      expect(items.map((e) => e.id), ['x2', 'x1']);
      expect(items.first.endYear, 2025);
    });
  });
}
