import 'package:flutter/material.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final TextEditingController skillController = TextEditingController();

  List<String> skills = [];
  List<String> interests = [];

  void addSkill() {
    if (skillController.text.trim().isNotEmpty) {
      setState(() {
        skills.add(skillController.text.trim());
        skillController.clear();
      });
    }
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D103D),
      appBar: AppBar(
        title: const Text('Skills & Interests'),
        backgroundColor: const Color(0xFF0D103D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Skills',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            TextField(
              controller: skillController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter a skill',
                hintStyle: const TextStyle(color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: addSkill,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  onDeleted: () {
                    setState(() {
                      skills.remove(skill);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const Text(
              'My Interests',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Add your interests',
                hintStyle: TextStyle(color: Colors.white70),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    interests.add(value.trim());
                  });
                }
              },
            ),
            Wrap(
              spacing: 8,
              children: interests.map((interest) {
                return Chip(
                  label: Text(interest),
                  onDeleted: () {
                    setState(() {
                      interests.remove(interest);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
