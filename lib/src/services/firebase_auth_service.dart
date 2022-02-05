import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/my_user.dart';
import 'api_repository.dart';
import 'auth_service.dart';

class FirebaseAuthService with NetworkLoggy implements AuthService {
  FirebaseAuthService() {
    _authStateController.add(_firebaseAuth.currentUser);
  }

  final _firebaseAuth = FirebaseAuth.instance;
  final _apiRepository = GetIt.I.get<APIRepository>();
  final _authStateController = StreamController<User?>();

  MyUser? _userFromFirebase(User? user) =>
      user != null ? MyUser(uid: user.uid) : null;

  @override
  Stream<MyUser?> get onAuthStateChanged =>
      _authStateController.stream.map(_userFromFirebase);

  Future<void> _saveUserToMongo(User user) async {
    try {
      final savedUser = await _apiRepository.createMongoUser(user);
      loggy.info('User successfully created on mongodb\n$savedUser');
    } on Exception {
      await _firebaseAuth.currentUser!.delete();
      loggy.info('Successfully deleted the Firebase user\n$user');
      throw PlatformException(code: 'mongo-create-user-failed');
    }
  }

  @override
  Future<MyUser> signInWithFacebook() async {
    // Trigger the sign-in flow
    final loginResult = await FacebookAuth.instance.login();
    switch (loginResult.status) {
      case LoginStatus.success:
        // Create an user credential from the access token
        final userCredential = await _firebaseAuth.signInWithCredential(
          FacebookAuthProvider.credential(loginResult.accessToken!.token),
        );
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _saveUserToMongo(userCredential.user!);
        }
        _authStateController.add(userCredential.user);

        return _userFromFirebase(userCredential.user)!;
      case LoginStatus.cancelled:
        throw PlatformException(code: 'aborted-by-user');
      case LoginStatus.failed:
        throw PlatformException(code: 'sign-in-failed');
      case LoginStatus.operationInProgress:
        throw PlatformException(code: 'sign-in-operation-in-progress');
    }
  }

  @override
  Future<MyUser> signInWithGoogle() async {
    // Trigger the sign-in flow
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw PlatformException(code: 'aborted-by-user');
    }
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
    _authStateController.add(userCredential.user);

    return _userFromFirebase(userCredential.user)!;
  }

  @override
  Future<MyUser?> currentUser() async =>
      _userFromFirebase(_firebaseAuth.currentUser);

  @override
  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await GoogleSignIn().signOut();
    _authStateController.add(null);

    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {
    _authStateController.close();
  }
}
