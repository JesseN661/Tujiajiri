import 'package:equatable/equatable.dart';

import 'application_status.dart';

class JobApplication extends Equatable {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.employerId,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.coverLetter = '',
  });

  final String id;
  final String jobId;
  final String applicantId;
  final String employerId;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final String coverLetter;

  @override
  List<Object?> get props => [
    id,
    jobId,
    applicantId,
    employerId,
    status,
    appliedAt,
    updatedAt,
    coverLetter,
  ];
}
