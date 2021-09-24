import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/my_user.dart';
import 'auth_service.dart';
import 'spring_service.dart';

class FirebaseAuthService with NetworkLoggy implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SpringService _springService = GetIt.I.get<SpringService>();

  MyUser? _userFromFirebase(User? user) =>
      user != null ? MyUser(uid: user.uid) : null;

  @override
  Stream<MyUser?> get onAuthStateChanged =>
      _firebaseAuth.authStateChanges().map(_userFromFirebase);

  @override
  Future<MyUser> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      // Create a credential from the access token
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(
        FacebookAuthProvider.credential(loginResult.accessToken!.token),
      );

      if (userCredential.additionalUserInfo!.isNewUser) {
        try {
          final user =
              await _springService.createMongoUser(userCredential.user!);
          loggy.info('User created on mongodb\n$user');
        } on Exception {
          await _firebaseAuth.currentUser!.delete();
          throw PlatformException(
            code: 'MONGODB_CREATE_USER_ERROR',
            message: 'Could not create user on MongoDB',
          );
        }
      }

      return _userFromFirebase(userCredential.user)!;
    } else if (loginResult.status == LoginStatus.operationInProgress) {
      throw PlatformException(
        code: 'ERROR_OPERATION_IN_PROGRESS',
        message: 'You have a previous login operation in progress',
      );
    } else if (loginResult.status == LoginStatus.cancelled) {
      throw PlatformException(
        code: 'ERROR_CANCELLED',
        message: 'Sign in aborted by user',
      );
    } else {
      throw PlatformException(
        code: 'ERROR_FAILED',
        message: 'Sign in failed',
      );
    }
  }

  @override
  Future<MyUser> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );

        if (userCredential.additionalUserInfo!.isNewUser) {
          try {
            final user =
                await _springService.createMongoUser(userCredential.user!);
            loggy.info('User created on mongodb\n$user');
          } on Exception {
            await _firebaseAuth.currentUser!.delete();
            throw PlatformException(
              code: 'MONGODB_CREATE_USER_ERROR',
              message: 'Could not create user on MongoDB',
            );
          }
        }

        return _userFromFirebase(userCredential.user)!;
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    }
  }

  @override
  Future<MyUser> currentUser() async {
    final User? user = _firebaseAuth.currentUser;

    return _userFromFirebase(user)!;
  }

  @override
  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {}
}
