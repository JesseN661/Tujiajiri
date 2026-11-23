import 'package:flutter/material.dart';

import '../core/navigation/home_shell.dart';
import '../core/session/role_repository.dart';
import '../core/session/user_role.dart';
import 'destinations.dart';

/// Loads the signed-in user's role and shows the matching tabs.
///
/// If the role cannot be read (no profile yet, offline, or denied by the
/// rules), the user is shown the seeker tabs, the safest default.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key, required this.uid, required this.roles});

  final String uid;
  final RoleRepository roles;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      stream: roles.watchRole(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data ?? UserRole.seeker;
        // A new key resets the selected tab when the role changes.
        return HomeShell(
          key: ValueKey(role),
          destinations: destinationsFor(role),
        );
      },
    );
  }
}
