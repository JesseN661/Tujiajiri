import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tujiajiri/features/applications/data/models/application_model.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/repositories/application_repository.dart';

class FirestoreApplicationRepository implements ApplicationRepository {
  FirestoreApplicationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  // Sorted on the device, so this query needs no composite index.
  Stream<List<JobApplication>> _watch(String field, String value) {
    return _applications.where(field, isEqualTo: value).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs.map(ApplicationModel.fromDoc).toList()
        ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return items;
    });
  }

  @override
  Stream<List<JobApplication>> watchApplicantApplications(String applicantId) =>
      _watch('applicantId', applicantId);

  @override
  Stream<List<JobApplication>> watchEmployerApplications(String employerId) =>
      _watch('employerId', employerId);

  @override
  Future<bool> exists(String applicationId) async =>
      (await _applications.doc(applicationId).get()).exists;

  @override
  Future<void> submit(JobApplication application) => _applications
      .doc(application.id)
      .set(ApplicationModel.toMap(application));

  @override
  Future<void> updateStatus(String applicationId, ApplicationStatus status) =>
      _applications.doc(applicationId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });

  @override
  Future<void> withdraw(String applicationId) =>
      _applications.doc(applicationId).delete();
}
