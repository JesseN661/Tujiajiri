import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/profile/domain/entities/education.dart';
import 'package:tujiajiri/features/profile/domain/entities/user_profile.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/onboarding_cubit.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/onboarding_state.dart';

import '../test_support.dart';

void main() {
  late FakeProfileRepository repository;
  late OnboardingCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = OnboardingCubit(repository: repository, user: testUser);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test(
      'new user starts onboarding with the account name prefilled',
      () async {
        await cubit.load();

        expect(cubit.state.status, OnboardingStatus.inProgress);
        expect(cubit.state.step, OnboardingStep.personal);
        expect(cubit.state.fullName, 'Amina Uwase');
      },
    );

    test('finished profile skips onboarding', () async {
      repository.existing = const UserProfile(
        uid: 'u1',
        fullName: 'Amina Uwase',
        email: 'amina@example.com',
        onboardingComplete: true,
      );

      await cubit.load();

      expect(cubit.state.status, OnboardingStatus.ready);
    });

    test('unfinished saved profile resumes with its values', () async {
      repository.existing = const UserProfile(
        uid: 'u1',
        fullName: 'Amina U.',
        email: 'amina@example.com',
        phone: '0788123456',
      );

      await cubit.load();

      expect(cubit.state.status, OnboardingStatus.inProgress);
      expect(cubit.state.fullName, 'Amina U.');
      expect(cubit.state.phone, '0788123456');
    });

    test('a Firestore error is reported as loadFailed', () async {
      repository.failing = true;

      await cubit.load();

      expect(cubit.state.status, OnboardingStatus.loadFailed);
    });
  });

  group('personal step', () {
    test('invalid details show a message and stay on step 1', () async {
      await cubit.load();

      cubit.submitPersonal(fullName: 'Amina', phone: '12', location: 'Kigali');

      expect(cubit.state.step, OnboardingStep.personal);
      expect(cubit.state.message, 'Enter a valid phone number.');
    });

    test('valid details are trimmed and move to education', () async {
      await cubit.load();

      cubit.submitPersonal(
        fullName: ' Amina Uwase ',
        phone: '0788123456',
        location: ' Kigali ',
      );

      expect(cubit.state.step, OnboardingStep.education);
      expect(cubit.state.fullName, 'Amina Uwase');
      expect(cubit.state.location, 'Kigali');
    });
  });

  group('education and experience lists', () {
    test('add, edit and remove education', () {
      cubit.saveEducation(sampleEducation);
      expect(cubit.state.education, [sampleEducation]);

      const edited = Education(
        id: 'e1',
        school: 'IPRC Huye',
        degree: 'Diploma',
        startYear: 2019,
      );
      cubit.saveEducation(edited);
      expect(cubit.state.education.single.school, 'IPRC Huye');

      cubit.removeEducation('e1');
      expect(cubit.state.education, isEmpty);
    });

    test('add and remove experience', () {
      cubit.saveExperience(sampleExperience);
      expect(cubit.state.experience, [sampleExperience]);

      cubit.removeExperience('x1');
      expect(cubit.state.experience, isEmpty);
    });

    test('newId returns a different id each time', () {
      expect(cubit.newId(), isNot(cubit.newId()));
    });
  });

  group('finish', () {
    test('saves profile, education and experience, then is ready', () async {
      await cubit.load();
      cubit.submitPersonal(
        fullName: 'Amina Uwase',
        phone: '0788123456',
        location: 'Kigali',
      );
      cubit.saveEducation(sampleEducation);
      cubit.saveExperience(sampleExperience);

      await cubit.finish();

      expect(cubit.state.status, OnboardingStatus.ready);
      expect(repository.savedProfile?.uid, 'u1');
      expect(repository.savedProfile?.email, 'amina@example.com');
      expect(repository.savedProfile?.phone, '0788123456');
      expect(repository.savedEducation, [sampleEducation]);
      expect(repository.savedExperience, [sampleExperience]);
    });

    test('a save error keeps the user on the form with a message', () async {
      await cubit.load();
      repository.failing = true;

      await cubit.finish();

      expect(cubit.state.status, OnboardingStatus.inProgress);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.message, contains('Could not save'));
    });
  });
}
