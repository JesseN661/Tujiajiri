import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;

import 'app/auth_gate.dart';
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
    ),
  );
}

class TujiajiriApp extends StatelessWidget {
  const TujiajiriApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
  });

  // Passed in (not created here) so tests can use fakes instead of Firebase.
  final AuthRepository authRepository;
  final UserProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserProfileRepository>.value(
      value: profileRepository,
      child: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(repository: authRepository),
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
