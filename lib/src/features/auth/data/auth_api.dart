import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthApi {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Stream<User?> get idTokenChanges;

  Future<String?> getIdToken();

  Future<User> signInWithFacebook();

  Future<User> signInWithGoogle();

  Future<void> signOut();
}
