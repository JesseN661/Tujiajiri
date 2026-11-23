import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tujiajiri/features/applications/domain/application_failure.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/repositories/application_repository.dart';
import 'package:tujiajiri/features/applications/domain/usecases/submit_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';
import 'package:tujiajiri/features/applications/domain/usecases/withdraw_application.dart';

import 'applications_state.dart';

class ApplicationsCubit extends Cubit<ApplicationsState> {
  ApplicationsCubit({
    required this._repository,
    required SubmitApplication submitApplication,
    required UpdateApplicationStatus updateApplicationStatus,
    required WithdrawApplication withdrawApplication,
    required this.currentUserId,
  }) : _submit = submitApplication,
       _updateStatus = updateApplicationStatus,
       _withdraw = withdrawApplication,
       super(const ApplicationsState());

  final ApplicationRepository _repository;
  final SubmitApplication _submit;
  final UpdateApplicationStatus _updateStatus;
  final WithdrawApplication _withdraw;

  /// The signed-in user's id (comes from authentication).
  final String Function() currentUserId;

  StreamSubscription<List<JobApplication>>? _subscription;

  /// Starts (or restarts) listening to this user's applications.
  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: ApplicationsStatus.loading));
    _subscription = _repository
        .watchApplicantApplications(currentUserId())
        .listen(
          (applications) => emit(
            state.copyWith(
              status: ApplicationsStatus.loaded,
              applications: applications,
            ),
          ),
          onError: (Object _) => emit(
            state.copyWith(
              status: ApplicationsStatus.failure,
              message: 'Could not load your applications.',
            ),
          ),
        );
  }

  /// Returns null on success, or a user-friendly error message.
  Future<String?> submit({
    required String jobId,
    required String employerId,
    String jobTitle = '',
    String employerName = '',
    String coverLetter = '',
  }) async {
    try {
      await _submit(
        jobId: jobId,
        applicantId: currentUserId(),
        employerId: employerId,
        coverLetter: coverLetter,
        jobTitle: jobTitle,
        employerName: employerName,
      );
      return null;
    } on ApplicationFailure catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> withdraw(JobApplication application) => _run(
    () => _withdraw(application, currentUserId()),
    success: 'Application withdrawn.',
  );

  Future<void> updateStatus(
    JobApplication application,
    ApplicationStatus next,
  ) => _run(
    () => _updateStatus(application, next),
    success: 'Status changed to ${next.label}.',
  );

  Future<void> _run(
    Future<void> Function() action, {
    required String success,
  }) async {
    try {
      await action();
      _notify(success);
    } on ApplicationFailure catch (e) {
      _notify(e.message);
    } catch (_) {
      _notify('Something went wrong. Please try again.');
    }
  }

  void _notify(String message) {
    if (isClosed) return;
    emit(state.copyWith(message: message, feedbackId: state.feedbackId + 1));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
