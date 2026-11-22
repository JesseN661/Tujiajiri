import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/jobs/presentation/jobs_screen.dart';
import 'features/jobs/state/job_search_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TujiajiriApp());
}

class TujiajiriApp extends StatelessWidget {
  const TujiajiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JobSearchController>(
      create: (_) => JobSearchController(),
      child: MaterialApp(
        title: 'Tujiajiri',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF146C43),
          ),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const JobsScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
