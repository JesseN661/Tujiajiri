import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tujiajiri/features/applications/domain/application_failure.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/repositories/application_repository.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';

import 'applications_state.dart';

/// Applications received for the signed-in employer's jobs.
class EmployerApplicationsCubit extends Cubit<ApplicationsState> {
  EmployerApplicationsCubit({
    required ApplicationRepository repository,
    required UpdateApplicationStatus updateApplicationStatus,
    required this.currentUserId,
  }) : _received = repository,
       _changeStatus = updateApplicationStatus,
       super(const ApplicationsState());

  final ApplicationRepository _received;
  final UpdateApplicationStatus _changeStatus;

  /// Returns the signed-in employer's id (empty if nobody is signed in).
  final String Function() currentUserId;

  StreamSubscription<List<JobApplication>>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: ApplicationsStatus.loading));
    _subscription = _received
        .watchEmployerApplications(currentUserId())
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
              message: 'Could not load received applications.',
            ),
          ),
        );
  }

  Future<void> updateStatus(
    JobApplication application,
    ApplicationStatus next,
  ) async {
    try {
      await _changeStatus(application, next);
      _notify('Status changed to ${next.label}.');
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
