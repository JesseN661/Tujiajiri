import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'skills_screen.dart';
import 'preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final educationController = TextEditingController();
  final experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    nameController.text = prefs.getString('fullName') ?? '';
    emailController.text = prefs.getString('email') ?? '';
    phoneController.text = prefs.getString('phone') ?? '';
    educationController.text = prefs.getString('education') ?? '';
    experienceController.text = prefs.getString('experience') ?? '';
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('fullName', nameController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('education', educationController.text);
    await prefs.setString('experience', experienceController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    educationController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 45),
              ),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SkillsScreen(),
                    ),
                  );
                },
                child: const Text('Skills & Interests'),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreferencesScreen(),
                    ),
                  );
                },
                child: const Text('Preferences'),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Personal Information',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            buildField('Full Name', nameController),
            buildField('Email', emailController),
            buildField('Phone Number', phoneController),

            const SizedBox(height: 20),

            const Text(
              'Education',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            buildField('Education Details', educationController),

            const SizedBox(height: 20),

            const Text(
              'Experience',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            buildField('Work Experience', experienceController),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
