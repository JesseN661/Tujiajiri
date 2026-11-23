import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/domain/entities/app_user.dart';
import '../../auth/presentation/bloc/auth_cubit.dart';
import 'pages/profile_details_page.dart';
import 'preferences_screen.dart';
import 'skills_screen.dart';

/// Profile menu: details (saved in Firestore), skills and preferences.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select((AuthCubit cubit) => cubit.state.user);

    return Scaffold(
      backgroundColor: const Color(0xFF0D103D),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF0D103D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 45),
              ),
            ),
            const SizedBox(height: 12),
            if (user != null) ...[
              Text(
                user.displayName.isEmpty ? user.email : user.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => _open(context, const ProfileDetailsPage()),
              child: const Text('Profile details'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _open(context, const SkillsScreen()),
              child: const Text('Skills & Interests'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _open(context, const PreferencesScreen()),
              child: const Text('Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
