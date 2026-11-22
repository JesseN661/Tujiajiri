import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'features/applications/data/repositories/firestore_application_repository.dart';
import 'features/applications/domain/usecases/submit_application.dart';
import 'features/applications/domain/usecases/update_application_status.dart';
import 'features/applications/domain/usecases/withdraw_application.dart';
import 'features/applications/presentation/bloc/applications_cubit.dart';
import 'features/applications/presentation/bloc/employer_applications_cubit.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/jobs/presentation/jobs_screen.dart';
import 'features/jobs/state/job_search_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const TujiajiriApp());
}

class TujiajiriApp extends StatelessWidget {
  const TujiajiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    final applicationRepository = FirestoreApplicationRepository(
      FirebaseFirestore.instance,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationsCubit>(
          create: (_) => ApplicationsCubit(
            repository: applicationRepository,
            submitApplication: SubmitApplication(applicationRepository),
            updateApplicationStatus: UpdateApplicationStatus(
              applicationRepository,
            ),
            withdrawApplication: WithdrawApplication(applicationRepository),
            currentUserId: () => FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ),
        BlocProvider<EmployerApplicationsCubit>(
          create: (_) => EmployerApplicationsCubit(
            repository: applicationRepository,
            updateApplicationStatus: UpdateApplicationStatus(
              applicationRepository,
            ),
            currentUserId: () => FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ),
      ],
      child: ChangeNotifierProvider<JobSearchController>(
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
