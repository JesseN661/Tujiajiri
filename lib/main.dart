import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;

import 'app/auth_gate.dart';
import 'features/applications/data/repositories/firestore_application_repository.dart';
import 'features/applications/domain/repositories/application_repository.dart';
import 'features/applications/domain/usecases/submit_application.dart';
import 'features/applications/domain/usecases/update_application_status.dart';
import 'features/applications/domain/usecases/withdraw_application.dart';
import 'features/applications/presentation/bloc/applications_cubit.dart';
import 'features/applications/presentation/bloc/employer_applications_cubit.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/jobs/presentation/jobs_screen.dart';
import 'features/jobs/state/job_search_controller.dart';
import 'features/profile/data/firestore_user_profile_repository.dart';
import 'features/profile/domain/repositories/user_profile_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    TujiajiriApp(
      authRepository: FirebaseAuthRepository(),
      profileRepository: FirestoreUserProfileRepository(),
      applicationRepository: FirestoreApplicationRepository(
        FirebaseFirestore.instance,
      ),
    ),
  );
}

class TujiajiriApp extends StatelessWidget {
  const TujiajiriApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    required this.applicationRepository,
  });

  // Passed in (not created here) so tests can use fakes instead of Firebase.
  final AuthRepository authRepository;
  final UserProfileRepository profileRepository;
  final ApplicationRepository applicationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserProfileRepository>.value(
      value: profileRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(repository: authRepository),
          ),
          // Applications cubits (Jesse's feature) are provided app-wide.
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
            home: AuthGate(homeBuilder: (_) => const JobsScreen()),
          ),
        ),
      ),
    );
  }
}
