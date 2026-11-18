import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/job.dart';

class JobRepository {
  final FirebaseFirestore _firestore;

  JobRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jobs =>
      _firestore.collection('jobs');

  /// Stream published jobs and update the app when Firestore changes.
  Stream<List<Job>> watchPublishedJobs() {
    return _jobs.where('status', isEqualTo: 'published').snapshots().map((
      snapshot,
    ) {
      final jobs = snapshot.docs
          .map((document) => Job.fromMap(document.id, document.data()))
          .toList();

      jobs.sort((a, b) => a.title.compareTo(b.title));
      return jobs;
    });
  }

  /// Read a single job by its Firestore document ID.
  Future<Job?> getJobById(String jobId) async {
    final document = await _jobs.doc(jobId).get();

    if (!document.exists) {
      return null;
    }

    return Job.fromMap(document.id, document.data()!);
  }

  /// Create a job listing.
  Future<String> createJob(Map<String, dynamic> data) async {
    final document = await _jobs.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  /// Update an existing job listing.
  Future<void> updateJob(String jobId, Map<String, dynamic> changes) async {
    await _jobs.doc(jobId).update(changes);
  }

  /// Delete a job listing.
  Future<void> deleteJob(String jobId) async {
    await _jobs.doc(jobId).delete();
  }
}
