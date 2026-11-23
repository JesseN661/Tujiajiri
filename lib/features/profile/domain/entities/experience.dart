import 'package:equatable/equatable.dart';

/// One job or placement, saved in `users/{uid}/experience/{id}`.
class Experience extends Equatable {
  const Experience({
    required this.id,
    required this.company,
    required this.role,
    required this.startYear,
    this.endYear,
    this.description = '',
  });

  final String id;
  final String company;
  final String role;
  final int startYear;

  /// Null means the user still works here.
  final int? endYear;
  final String description;

  @override
  List<Object?> get props => [
    id,
    company,
    role,
    startYear,
    endYear,
    description,
  ];
}
