class Job {
  final String id;
  final String title;
  final String employerId;
  final String employerName;
  final String description;
  final String location;
  final List<String> requiredSkills;
  final String employmentType;
  final String experienceLevel;
  final bool isVerified;
  final String status;

  const Job({
    required this.id,
    required this.title,
    required this.employerId,
    required this.employerName,
    required this.description,
    required this.location,
    required this.requiredSkills,
    required this.employmentType,
    required this.experienceLevel,
    required this.isVerified,
    required this.status,
  });

  factory Job.fromMap(String id, Map<String, dynamic> data) {
    return Job(
      id: id,
      title: data['title'] as String? ?? 'Untitled job',
      employerId: data['employerId'] as String? ?? '',
      employerName: data['employerName'] as String? ?? 'Employer not specified',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? 'Not specified',
      requiredSkills: List<String>.from(
        data['requiredSkills'] ?? const <String>[],
      ),
      employmentType: data['employmentType'] as String? ?? 'Not specified',
      experienceLevel: data['experienceLevel'] as String? ?? 'Not specified',
      isVerified: data['isVerified'] as bool? ?? false,
      status: data['status'] as String? ?? 'draft',
    );
  }
}
