import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/profile/domain/entities/user_profile.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/skills_cubit.dart';

import '../test_support.dart';

const _profile = UserProfile(
  uid: 'u1',
  fullName: 'Amina Uwase',
  email: 'amina@example.com',
  skills: ['Excel'],
  interests: ['Sales'],
);

void main() {
  late FakeProfileRepository repository;
  late SkillsCubit cubit;

  setUp(() {
    repository = FakeProfileRepository(existing: _profile);
    cubit = SkillsCubit(repository: repository, uid: 'u1');
  });

  tearDown(() => cubit.close());

  test('load shows the saved skills and interests', () async {
    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.skills, ['Excel']);
    expect(cubit.state.interests, ['Sales']);
  });

  test('adding a skill saves it to the profile', () async {
    await cubit.load();
    await cubit.addSkill('  Customer service ');

    expect(cubit.state.skills, ['Excel', 'Customer service']);
    expect(repository.savedProfile?.skills, ['Excel', 'Customer service']);
  });

  test('empty and duplicate skills are ignored', () async {
    await cubit.load();
    await cubit.addSkill('   ');
    await cubit.addSkill('excel');

    expect(cubit.state.skills, ['Excel']);
    expect(repository.savedProfile, isNull);
  });

  test('removing an interest saves the change', () async {
    await cubit.load();
    await cubit.removeInterest('Sales');

    expect(cubit.state.interests, isEmpty);
    expect(repository.savedProfile?.interests, isEmpty);
  });

  test('a failed save keeps the old list and shows an error', () async {
    await cubit.load();
    repository.failing = true;
    await cubit.addSkill('Driving');

    expect(cubit.state.skills, ['Excel']);
    expect(cubit.state.error, 'Could not save. Please try again.');
  });

  test('a failed load shows an error', () async {
    repository.failing = true;
    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.error, 'Could not load your skills.');
  });
}
