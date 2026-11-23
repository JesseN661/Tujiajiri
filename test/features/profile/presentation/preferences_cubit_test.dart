import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/preferences_cubit.dart';

void main() {
  test('load reads the saved preferences', () async {
    SharedPreferences.setMockInitialValues({
      'darkMode': false,
      'jobSorting': 'A-Z',
    });
    final cubit = PreferencesCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.darkMode, isFalse);
    expect(cubit.state.notifications, isTrue);
    expect(cubit.state.jobSorting, 'A-Z');
  });

  test('changes are saved on the device', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = PreferencesCubit();
    addTearDown(cubit.close);

    await cubit.setNotifications(false);
    await cubit.setJobSorting('Oldest');

    final prefs = await SharedPreferences.getInstance();
    expect(cubit.state.notifications, isFalse);
    expect(prefs.getBool('notifications'), isFalse);
    expect(prefs.getString('jobSorting'), 'Oldest');
  });
}
