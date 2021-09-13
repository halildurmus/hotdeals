import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/my_user.dart';
import '../services/auth_service.dart';

class SignInManager with NetworkLoggy {
  SignInManager({required this.auth, required this.isLoading});

  final AuthService auth;
  final ValueNotifier<bool> isLoading;

  Future<MyUser> _signIn(Future<MyUser> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } on Exception catch (e) {
      loggy.error(e, e);
      isLoading.value = false;
      rethrow;
    }
  }

  Future<MyUser> signInWithFacebook() async {
    return _signIn(auth.signInWithFacebook);
  }

  Future<MyUser> signInWithGoogle() async {
    return _signIn(auth.signInWithGoogle);
  }
}
