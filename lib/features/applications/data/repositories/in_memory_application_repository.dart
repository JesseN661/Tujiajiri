import 'dart:async';

import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/repositories/application_repository.dart';

/// Temporary stand-in for Firestore so the UI can be built and tested early.
class InMemoryApplicationRepository implements ApplicationRepository {
  InMemoryApplicationRepository([Iterable<JobApplication> initial = const []]) {
    for (final application in initial) {
      _items[application.id] = application;
    }
  }

  final Map<String, JobApplication> _items = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Stream<List<JobApplication>> _watch(
    bool Function(JobApplication) matches,
  ) async* {
    List<JobApplication> snapshot() =>
        _items.values.where(matches).toList()
          ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

    yield snapshot();
    await for (final _ in _changes.stream) {
      yield snapshot();
    }
  }

  @override
  Stream<List<JobApplication>> watchApplicantApplications(String applicantId) =>
      _watch((a) => a.applicantId == applicantId);

  @override
  Stream<List<JobApplication>> watchEmployerApplications(String employerId) =>
      _watch((a) => a.employerId == employerId);

  @override
  Future<bool> exists(String applicationId) async =>
      _items.containsKey(applicationId);

  @override
  Future<void> submit(JobApplication application) async {
    _items[application.id] = application;
    _changes.add(null);
  }

  @override
  Future<void> updateStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    final current = _items[applicationId];
    if (current == null) return;
    _items[applicationId] = current.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _changes.add(null);
  }

  @override
  Future<void> withdraw(String applicationId) async {
    _items.remove(applicationId);
    _changes.add(null);
  }
}
