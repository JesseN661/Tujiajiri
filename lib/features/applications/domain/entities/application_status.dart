enum ApplicationStatus {
  submitted('Submitted'),
  underReview('Under Review'),
  accepted('Accepted'),
  rejected('Rejected');

  const ApplicationStatus(this.label);
  final String label;

  bool get isFinal =>
      this == ApplicationStatus.accepted || this == ApplicationStatus.rejected;

  /// Statuses an employer can move an application to.
  List<ApplicationStatus> get nextOptions => switch (this) {
    ApplicationStatus.submitted => const [
      ApplicationStatus.underReview,
      ApplicationStatus.accepted,
      ApplicationStatus.rejected,
    ],
    ApplicationStatus.underReview => const [
      ApplicationStatus.accepted,
      ApplicationStatus.rejected,
    ],
    ApplicationStatus.accepted || ApplicationStatus.rejected => const [],
  };

  static ApplicationStatus fromName(String? name) =>
      ApplicationStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => ApplicationStatus.submitted,
      );
}
