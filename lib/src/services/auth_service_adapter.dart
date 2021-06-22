import 'dart:async';

import '../models/my_user.dart';
import 'auth_service.dart';
import 'firebase_auth_service.dart';

class AuthServiceAdapter implements AuthService {
  AuthServiceAdapter() {
    _setup();
  }

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  late StreamSubscription<MyUser?> _firebaseAuthSubscription;

  void _setup() {
    _firebaseAuthSubscription = _firebaseAuthService.onAuthStateChanged
        .listen(_onAuthStateChangedController.add, onError: (Object error) {
      _onAuthStateChangedController.addError(error);
    });
  }

  @override
  void dispose() {
    _firebaseAuthSubscription.cancel();
    _onAuthStateChangedController.close();
  }

  final StreamController<MyUser?> _onAuthStateChangedController =
      StreamController<MyUser?>.broadcast();

  @override
  Stream<MyUser?> get onAuthStateChanged =>
      _onAuthStateChangedController.stream;

  @override
  Future<MyUser> currentUser() => _firebaseAuthService.currentUser();

  @override
  Future<MyUser> signInWithFacebook() =>
      _firebaseAuthService.signInWithFacebook();

  @override
  Future<MyUser> signInWithGoogle() => _firebaseAuthService.signInWithGoogle();

  @override
  Future<void> signOut() => _firebaseAuthService.signOut();
}
