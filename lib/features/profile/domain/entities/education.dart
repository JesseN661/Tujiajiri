import 'package:equatable/equatable.dart';

/// One school or course, saved in `users/{uid}/education/{id}`.
class Education extends Equatable {
  const Education({
    required this.id,
    required this.school,
    required this.degree,
    required this.startYear,
    this.fieldOfStudy = '',
    this.endYear,
  });

  final String id;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final int startYear;

  /// Null means the user is still studying here.
  final int? endYear;

  @override
  List<Object?> get props => [
    id,
    school,
    degree,
    fieldOfStudy,
    startYear,
    endYear,
  ];
}
