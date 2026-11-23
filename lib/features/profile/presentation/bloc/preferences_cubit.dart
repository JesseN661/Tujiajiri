import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit() : super(const PreferencesState());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    emit(
      PreferencesState(
        darkMode: prefs.getBool('darkMode') ?? true,
        notifications: prefs.getBool('notifications') ?? true,
        jobSorting: prefs.getString('jobSorting') ?? 'Newest',
      ),
    );
  }

  Future<void> setDarkMode(bool value) =>
      _save(state.copyWith(darkMode: value));

  Future<void> setNotifications(bool value) =>
      _save(state.copyWith(notifications: value));

  Future<void> setJobSorting(String value) =>
      _save(state.copyWith(jobSorting: value));

  Future<void> _save(PreferencesState next) async {
    emit(next);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', next.darkMode);
    await prefs.setBool('notifications', next.notifications);
    await prefs.setString('jobSorting', next.jobSorting);
  }
}
