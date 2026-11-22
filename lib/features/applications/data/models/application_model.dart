import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';

/// Converts between Firestore documents and [JobApplication].
class ApplicationModel {
  const ApplicationModel._();

  static JobApplication fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return JobApplication(
      id: doc.id,
      jobId: data['jobId'] as String? ?? '',
      applicantId: data['applicantId'] as String? ?? '',
      employerId: data['employerId'] as String? ?? '',
      status: ApplicationStatus.fromName(data['status'] as String?),
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      coverLetter: data['coverLetter'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      employerName: data['employerName'] as String? ?? '',
    );
  }

  static Map<String, dynamic> toMap(JobApplication a) => {
    'jobId': a.jobId,
    'applicantId': a.applicantId,
    'employerId': a.employerId,
    'status': a.status.name,
    'appliedAt': Timestamp.fromDate(a.appliedAt),
    'updatedAt': Timestamp.fromDate(a.updatedAt),
    'coverLetter': a.coverLetter,
    'jobTitle': a.jobTitle,
    'employerName': a.employerName,
  };
}
