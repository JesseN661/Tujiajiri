import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/bloc/auth_cubit.dart';
import '../domain/repositories/user_profile_repository.dart';
import 'bloc/skills_cubit.dart';
import 'bloc/skills_state.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SkillsCubit(
        repository: context.read<UserProfileRepository>(),
        uid: context.read<AuthCubit>().state.user?.uid ?? '',
      )..load(),
      child: const _SkillsView(),
    );
  }
}

class _SkillsView extends StatefulWidget {
  const _SkillsView();

  @override
  State<_SkillsView> createState() => _SkillsViewState();
}

class _SkillsViewState extends State<_SkillsView> {
  final TextEditingController skillController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  void addSkill() {
    context.read<SkillsCubit>().addSkill(skillController.text);
    skillController.clear();
  }

  void addInterest() {
    context.read<SkillsCubit>().addInterest(interestController.text);
    interestController.clear();
  }

  @override
  void dispose() {
    skillController.dispose();
    interestController.dispose();
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
      body: BlocConsumer<SkillsCubit, SkillsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cubit = context.read<SkillsCubit>();

          return SingleChildScrollView(
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
                  onSubmitted: (_) => addSkill(),
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
                  children: state.skills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      onDeleted: () => cubit.removeSkill(skill),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                const Text(
                  'My Interests',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                TextField(
                  controller: interestController,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => addInterest(),
                  decoration: InputDecoration(
                    hintText: 'Add your interests',
                    hintStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: addInterest,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: state.interests.map((interest) {
                    return Chip(
                      label: Text(interest),
                      onDeleted: () => cubit.removeInterest(interest),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
