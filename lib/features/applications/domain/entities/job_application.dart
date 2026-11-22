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
    this.jobTitle = '',
    this.employerName = '',
  });

  final String id;
  final String jobId;
  final String applicantId;
  final String employerId;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final String coverLetter;

  /// Snapshot of the job when the user applied, so the tracker needs no extra reads.
  final String jobTitle;
  final String employerName;

  JobApplication copyWith({ApplicationStatus? status, DateTime? updatedAt}) {
    return JobApplication(
      id: id,
      jobId: jobId,
      applicantId: applicantId,
      employerId: employerId,
      status: status ?? this.status,
      appliedAt: appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverLetter: coverLetter,
      jobTitle: jobTitle,
      employerName: employerName,
    );
  }

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
    jobTitle,
    employerName,
  ];
}
