import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../../../core/hotdeals_api.dart';
import '../../../core/hotdeals_repository.dart';
import 'auth_api.dart';

final authApiProvider = Provider<AuthApi>(
  (ref) =>
      FirebaseAuthRepository(ref.read, firebaseAuth: FirebaseAuth.instance),
  name: 'AuthApiProvider',
);

final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(authApiProvider).authStateChanges,
  name: 'AuthStateChangesProvider',
);

class FirebaseAuthRepository with NetworkLoggy implements AuthApi {
  FirebaseAuthRepository(
    Reader read, {
    required FirebaseAuth firebaseAuth,
  })  : _firebaseAuth = firebaseAuth,
        _hotdealsApi = read(hotdealsRepositoryProvider);

  final FirebaseAuth _firebaseAuth;
  final HotdealsApi _hotdealsApi;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _saveUserToMongo(User user) async {
    try {
      final savedUser = await _hotdealsApi.createMongoUser(user);
      loggy.info('User successfully created on mongodb\n$savedUser');
    } on Exception {
      await _firebaseAuth.currentUser!.delete();
      loggy.info('Successfully deleted the Firebase user\n$user');
      throw PlatformException(code: 'mongo-create-user-failed');
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    // Trigger the sign-in flow
    final loginResult = await FacebookAuth.instance.login();
    switch (loginResult.status) {
      case LoginStatus.success:
        // Create an user credential from the access token
        final userCredential = await _firebaseAuth.signInWithCredential(
            FacebookAuthProvider.credential(loginResult.accessToken!.token));
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _saveUserToMongo(userCredential.user!);
        }

        return userCredential.user!;
      case LoginStatus.cancelled:
        throw PlatformException(code: 'aborted-by-user');
      case LoginStatus.failed:
        throw PlatformException(code: 'sign-in-failed');
      case LoginStatus.operationInProgress:
        throw PlatformException(code: 'sign-in-operation-in-progress');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    // Trigger the sign-in flow
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw PlatformException(code: 'aborted-by-user');

    final googleAuth = await googleUser.authentication;
    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw PlatformException(code: 'missing-google-auth-token');
    }
    // Create a user credential from the access token
    final userCredential = await _firebaseAuth.signInWithCredential(
      GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      ),
    );

    if (userCredential.additionalUserInfo!.isNewUser) {
      await _saveUserToMongo(userCredential.user!);
    }

    return userCredential.user!;
  }

  @override
  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await GoogleSignIn().signOut();

    return _firebaseAuth.signOut();
  }
}
