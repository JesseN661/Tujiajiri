import 'package:equatable/equatable.dart';

class SkillsState extends Equatable {
  const SkillsState({
    this.isLoading = true,
    this.skills = const [],
    this.interests = const [],
    this.error,
  });

  final bool isLoading;
  final List<String> skills;
  final List<String> interests;
  final String? error;

  SkillsState copyWith({
    bool? isLoading,
    List<String>? skills,
    List<String>? interests,
    String? error,
  }) {
    return SkillsState(
      isLoading: isLoading ?? this.isLoading,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, skills, interests, error];
}
