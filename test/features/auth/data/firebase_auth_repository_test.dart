import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:tujiajiri/features/auth/data/firebase_auth_repository.dart';
import 'package:tujiajiri/features/auth/domain/auth_failure.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late MockGoogleSignIn google;

  setUp(() {
    google = MockGoogleSignIn();
    when(() => google.initialize()).thenAnswer((_) async {});
    when(() => google.signOut()).thenAnswer((_) async {});
  });

  FirebaseAuthRepository build(MockFirebaseAuth auth) =>
      FirebaseAuthRepository(auth: auth, googleSignIn: google);

  test('register creates an unverified user with the given name', () async {
    final auth = MockFirebaseAuth(verifyEmailAutomatically: false);

    final user = await build(auth).registerWithEmail(
      name: 'Amina',
      email: 'amina@example.com',
      password: 'abcdefg1',
    );

    expect(user.email, 'amina@example.com');
    expect(user.displayName, 'Amina');
    expect(user.emailVerified, isFalse);
  });

  test('sign in returns the signed-in user', () async {
    final auth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'u1', email: 'amina@example.com'),
    );

    final user = await build(auth)
        .signInWithEmail(email: 'amina@example.com', password: 'abcdefg1');

    expect(user.email, 'amina@example.com');
  });

  test('sign in failure becomes a friendly AuthFailure', () async {
    final auth = MockFirebaseAuth();
    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));

    expect(
      () => build(auth).signInWithEmail(email: 'a@b.co', password: 'x'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'Incorrect email or password.',
        ),
      ),
    );
  });

  test('password reset hides unknown accounts but reports other errors', () {
    final unknown = MockFirebaseAuth();
    whenCalling(Invocation.method(#sendPasswordResetEmail, null))
        .on(unknown)
        .thenThrow(FirebaseAuthException(code: 'user-not-found'));
    expect(build(unknown).sendPasswordReset('a@b.co'), completes);

    final offline = MockFirebaseAuth();
    whenCalling(Invocation.method(#sendPasswordResetEmail, null))
        .on(offline)
        .thenThrow(FirebaseAuthException(code: 'network-request-failed'));
    expect(
      build(offline).sendPasswordReset('a@b.co'),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('send verification fails when nobody is signed in', () {
    expect(
      build(MockFirebaseAuth()).sendEmailVerification(),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('reloadUser returns null when signed out', () async {
    expect(await build(MockFirebaseAuth()).reloadUser(), isNull);
  });

  test('reloadUser returns the current user when signed in', () async {
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'amina@example.com'),
    );

    final user = await build(auth).reloadUser();

    expect(user?.uid, 'u1');
  });

  test('sign out ends the Firebase session and clears Google', () async {
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'amina@example.com'),
    );

    await build(auth).signOut();

    expect(auth.currentUser, isNull);
    verify(() => google.signOut()).called(1);
  });

  test('sign out still succeeds if Google sign-out throws', () async {
    final auth = MockFirebaseAuth(signedIn: true);
    when(() => google.signOut()).thenThrow(StateError('not initialized'));

    await build(auth).signOut();

    expect(auth.currentUser, isNull);
  });

  test('cancelled Google sign-in reports a cancelled message', () {
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );

    expect(
      build(MockFirebaseAuth()).signInWithGoogle(),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          'Google sign-in was cancelled.',
        ),
      ),
    );
  });
}
