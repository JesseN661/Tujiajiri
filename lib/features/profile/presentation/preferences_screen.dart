import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool darkMode = true;
  bool notifications = true;
  String jobSorting = 'Newest';

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getBool('darkMode') ?? true;
      notifications = prefs.getBool('notifications') ?? true;
      jobSorting = prefs.getString('jobSorting') ?? 'Newest';
    });
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('darkMode', darkMode);
    await prefs.setBool('notifications', notifications);
    await prefs.setString('jobSorting', jobSorting);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D103D),
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: const Color(0xFF0D103D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(color: Colors.white),
              ),
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
                savePreferences();
              },
            ),
            SwitchListTile(
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.white),
              ),
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
                savePreferences();
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Preferred Job Sorting',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            DropdownButton<String>(
              value: jobSorting,
              dropdownColor: const Color(0xFF0D103D),
              style: const TextStyle(color: Colors.white),
              items: ['Newest', 'Oldest', 'A-Z']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    jobSorting = value;
                  });
                  savePreferences();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
