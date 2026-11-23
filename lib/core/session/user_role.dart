/// The role stored in `users/{uid}.role`. Users without a role are seekers.
enum UserRole {
  seeker,
  employer,
  admin;

  /// Reads a role name from Firestore; unknown or missing values mean seeker.
  static UserRole fromName(String? name) =>
      values.firstWhere((role) => role.name == name, orElse: () => seeker);

  /// Employers and admins review applications instead of submitting them.
  bool get reviewsApplications => this == employer || this == admin;
}
