enum ApplicationStatus {
  submitted('Submitted'),
  underReview('Under Review'),
  accepted('Accepted'),
  rejected('Rejected');

  const ApplicationStatus(this.label);
  final String label;

  bool get isFinal =>
      this == ApplicationStatus.accepted || this == ApplicationStatus.rejected;

  static ApplicationStatus fromName(String? name) =>
      ApplicationStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => ApplicationStatus.submitted,
      );
}
