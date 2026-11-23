import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/profile/domain/entities/education.dart';
import 'package:tujiajiri/features/profile/domain/entities/user_profile.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/profile_state.dart';

import '../test_support.dart';

const _profile = UserProfile(
  uid: 'u1',
  fullName: 'Amina Uwase',
  email: 'amina@example.com',
  phone: '0788123456',
  location: 'Kigali',
  onboardingComplete: true,
);

/// Lets the fake's streams deliver their events.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository(existing: _profile);
    cubit = ProfileCubit(repository: repository, uid: 'u1');
  });

  tearDown(() => cubit.close());

  test('start loads the profile, education and experience', () async {
    repository.savedEducation = [sampleEducation];
    repository.savedExperience = [sampleExperience];

    cubit.start();
    await _settle();

    expect(cubit.state.status, ProfileStatus.loaded);
    expect(cubit.state.profile, _profile);
    expect(cubit.state.education, [sampleEducation]);
    expect(cubit.state.experience, [sampleExperience]);
  });

  test('a read error moves to failure with a message', () async {
    repository.failing = true;

    cubit.start();
    await _settle();

    expect(cubit.state.status, ProfileStatus.failure);
    expect(cubit.state.isError, isTrue);
  });

  test('updatePersonal saves trimmed values and the view updates', () async {
    cubit.start();
    await _settle();

    await cubit.updatePersonal(
      fullName: ' Amina U. ',
      phone: '0788000111',
      location: 'Huye',
    );
    await _settle();

    expect(repository.savedProfile?.fullName, 'Amina U.');
    expect(cubit.state.profile?.location, 'Huye');
    expect(cubit.state.message, 'Personal details updated.');
    expect(cubit.state.isError, isFalse);
  });

  test('updatePersonal rejects invalid input without saving', () async {
    cubit.start();
    await _settle();

    await cubit.updatePersonal(
      fullName: 'Amina',
      phone: '12',
      location: 'Kigali',
    );

    expect(repository.savedProfile, isNull);
    expect(cubit.state.message, 'Enter a valid phone number.');
    expect(cubit.state.isError, isTrue);
  });

  test('education can be added, edited and deleted', () async {
    cubit.start();
    await _settle();

    await cubit.saveEducation(sampleEducation);
    await _settle();
    expect(cubit.state.education, [sampleEducation]);

    const edited = Education(
      id: 'e1',
      school: 'IPRC Huye',
      degree: 'Diploma',
      startYear: 2019,
    );
    await cubit.saveEducation(edited);
    await _settle();
    expect(cubit.state.education, [edited]);

    await cubit.deleteEducation('e1');
    await _settle();
    expect(cubit.state.education, isEmpty);
    expect(cubit.state.message, 'Education removed.');
  });

  test('experience can be added and deleted', () async {
    cubit.start();
    await _settle();

    await cubit.saveExperience(sampleExperience);
    await _settle();
    expect(cubit.state.experience, [sampleExperience]);

    await cubit.deleteExperience('x1');
    await _settle();
    expect(cubit.state.experience, isEmpty);
  });

  test('a failed write shows an error message', () async {
    cubit.start();
    await _settle();
    repository.failing = true;

    await cubit.saveEducation(sampleEducation);

    expect(cubit.state.isError, isTrue);
    expect(cubit.state.message, contains('Could not save'));
  });

  test('newId returns a different id each time', () {
    expect(cubit.newId(), isNot(cubit.newId()));
  });
}
