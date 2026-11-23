import 'package:flutter/material.dart';

import '../core/navigation/home_shell.dart';
import '../core/session/role_repository.dart';
import '../core/session/user_role.dart';
import 'destinations.dart';

/// Shows the tabs for the user's role (seeker if unknown).
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
        // New role: start again on the first tab.
        return HomeShell(
          key: ValueKey(role),
          destinations: destinationsFor(role),
        );
      },
    );
  }
}
