import 'package:equatable/equatable.dart';

class PreferencesState extends Equatable {
  const PreferencesState({
    this.darkMode = true,
    this.notifications = true,
    this.jobSorting = 'Newest',
  });

  final bool darkMode;
  final bool notifications;
  final String jobSorting;

  PreferencesState copyWith({
    bool? darkMode,
    bool? notifications,
    String? jobSorting,
  }) {
    return PreferencesState(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      jobSorting: jobSorting ?? this.jobSorting,
    );
  }

  @override
  List<Object?> get props => [darkMode, notifications, jobSorting];
}
