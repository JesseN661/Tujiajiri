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
    required ApplicationRepository repository,
    required SubmitApplication submitApplication,
    required UpdateApplicationStatus updateApplicationStatus,
    required WithdrawApplication withdrawApplication,
    required this.userId,
  }) : _repository = repository,
       _submit = submitApplication,
       _updateStatus = updateApplicationStatus,
       _withdraw = withdrawApplication,
       super(const ApplicationsState());

  final ApplicationRepository _repository;
  final SubmitApplication _submit;
  final UpdateApplicationStatus _updateStatus;
  final WithdrawApplication _withdraw;

  /// The signed-in user's id (comes from authentication).
  final String userId;

  StreamSubscription<List<JobApplication>>? _subscription;

  /// Starts (or restarts) listening to this user's applications.
  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: ApplicationsStatus.loading));
    _subscription = _repository
        .watchApplicantApplications(userId)
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

  Future<void> submit({
    required String jobId,
    required String employerId,
    String coverLetter = '',
  }) => _run(
    () => _submit(
      jobId: jobId,
      applicantId: userId,
      employerId: employerId,
      coverLetter: coverLetter,
    ),
    success: 'Application submitted.',
  );

  Future<void> withdraw(JobApplication application) => _run(
    () => _withdraw(application, userId),
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
