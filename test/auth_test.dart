import 'dart:developer';

import 'package:flutter_project/services/auth/auth_exceptions.dart';
import 'package:flutter_project/services/auth/auth_provider.dart';
import 'package:flutter_project/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  // Grouping Similar tests into One Group
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();
      test("Should Not be initialized to Begin With", () {
        expect(provider.isInitialized, false);
      });

      // Test to check whether Calling log Out function and checking whether
      //it throws the NotInitializedException Correctly
      test('Cannot Log Out If Not initialized', () {
        expect(provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()));
      });

      test('Should be able to initialized', () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      });

      test('User should be Null after Initialisation', () {
        expect(provider.currentUser, null);
      });

      // Checks whether the fuction gets executed before the timeout
      test('Should be able to initialise in less than 3 seconds', () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      }, timeout: const Timeout(Duration(seconds: 3)));

      test('Create User to delegate to login Function', () async {
        final badEmailUser =
            provider.createUser(email: 'foo@bar.com', password: 'anypassword');
        expect(badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()));
        final badPasswordUser =
            provider.createUser(email: 'any@email.com', password: 'foobar');
        expect(badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()));

        final newuser =
            await provider.createUser(email: 'abc@xyz.com', password: 'qwerty');

        expect(provider.currentUser, newuser);
        expect(newuser.isEmailVerified, false);
      });

      test('Logged in user should be able to get Verified', () async {
        await provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      });

      test('Should be able to Log out and log in again', () async {
        await provider.logOut();
        await provider.logIn(
          email: 'email',
          password: 'password',
        );
        final user = provider.currentUser;
        expect(user, isNotNull);
      });
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  // Getter Function that returns _isInitialized
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedException();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      return logIn(
        email: email,
        password: password,
      );
    }
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(
      isEmailVerified: false,
      email: 'foo@bar.com',
      id: 'my_id',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 2));
    _user = null; // marking User as NUll means User Logged Out
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'foo@bar.com',
      id: 'my_id',
    );
    _user = newUser;
  }
}
