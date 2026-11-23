import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tujiajiri/features/auth/domain/auth_failure.dart';
import 'package:tujiajiri/features/auth/domain/entities/app_user.dart';
import 'package:tujiajiri/features/auth/domain/repositories/auth_repository.dart';

const verifiedUser = AppUser(
  uid: 'u1',
  email: 'amina@example.com',
  displayName: 'Amina',
  emailVerified: true,
);

const unverifiedUser = AppUser(
  uid: 'u1',
  email: 'amina@example.com',
  displayName: 'Amina',
);

/// In-memory [AuthRepository] that records calls and can be told to fail.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _current = initialUser;

  final StreamController<AppUser?> _users = StreamController<AppUser?>();
  AppUser? _current;

  /// When set, the next call to any action throws this failure.
  AuthFailure? failure;

  /// What [reloadUser] returns, to simulate the user verifying their email.
  AppUser? reloadResult;

  final List<String> calls = [];

  /// Pushes a user (or null) to listeners, like Firebase would.
  void emitUser(AppUser? user) {
    _current = user;
    _users.add(user);
  }

  void _maybeFail() {
    final pending = failure;
    if (pending != null) throw pending;
  }

  @override
  Stream<AppUser?> watchUser() async* {
    yield _current;
    yield* _users.stream;
  }

  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    calls.add('register:$email');
    _maybeFail();
    final user = AppUser(uid: 'u1', email: email, displayName: name);
    emitUser(user);
    return user;
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    calls.add('signIn:$email');
    _maybeFail();
    emitUser(verifiedUser);
    return verifiedUser;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    calls.add('google');
    _maybeFail();
    emitUser(verifiedUser);
    return verifiedUser;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    calls.add('reset:$email');
    _maybeFail();
  }

  @override
  Future<void> sendEmailVerification() async {
    calls.add('verify');
    _maybeFail();
  }

  @override
  Future<AppUser?> reloadUser() async {
    calls.add('reload');
    _maybeFail();
    final user = reloadResult ?? _current;
    emitUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _maybeFail();
    emitUser(null);
  }
}

/// Pumps [page] inside an app that provides an [AuthCubit] backed by a fake.
///
/// [size] is the logical screen size (defaults to a tall phone portrait).
Future<FakeAuthRepository> pumpAuthPage(
  WidgetTester tester,
  Widget page, {
  FakeAuthRepository? repository,
  Size size = const Size(400, 900),
}) async {
  final repo = repository ?? FakeAuthRepository();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    BlocProvider(
      create: (_) => AuthCubit(repository: repo),
      child: MaterialApp(home: page),
    ),
  );
  await tester.pump();
  return repo;
}
