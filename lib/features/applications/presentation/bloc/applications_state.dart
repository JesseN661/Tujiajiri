import 'package:equatable/equatable.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';

enum ApplicationsStatus { loading, loaded, failure }

class ApplicationsState extends Equatable {
  const ApplicationsState({
    this.status = ApplicationsStatus.loading,
    this.applications = const [],
    this.message,
    this.feedbackId = 0,
  });

  final ApplicationsStatus status;
  final List<JobApplication> applications;

  /// One-off feedback for a snackbar. [feedbackId] changes every time, so the
  /// same message can be shown twice in a row.
  final String? message;
  final int feedbackId;

  int get inProgressCount =>
      applications.where((a) => !a.status.isFinal).length;
  int get decidedCount => applications.where((a) => a.status.isFinal).length;

  /// Note: [message] is cleared unless you pass it.
  ApplicationsState copyWith({
    ApplicationsStatus? status,
    List<JobApplication>? applications,
    String? message,
    int? feedbackId,
  }) {
    return ApplicationsState(
      status: status ?? this.status,
      applications: applications ?? this.applications,
      message: message,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [status, applications, message, feedbackId];
}
