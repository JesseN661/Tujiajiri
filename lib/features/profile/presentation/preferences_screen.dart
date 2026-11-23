import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/preferences_cubit.dart';
import 'bloc/preferences_state.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreferencesCubit()..load(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D103D),
        appBar: AppBar(
          title: const Text('Preferences'),
          backgroundColor: const Color(0xFF0D103D),
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<PreferencesCubit, PreferencesState>(
          builder: (context, state) {
            final cubit = context.read<PreferencesCubit>();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: state.darkMode,
                    onChanged: cubit.setDarkMode,
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Notifications',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: state.notifications,
                    onChanged: cubit.setNotifications,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Preferred Job Sorting',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  DropdownButton<String>(
                    value: state.jobSorting,
                    dropdownColor: const Color(0xFF0D103D),
                    style: const TextStyle(color: Colors.white),
                    items: ['Newest', 'Oldest', 'A-Z']
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        cubit.setJobSorting(value);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
