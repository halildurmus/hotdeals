import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../services/spring_service.dart';
import 'my_user.dart';
import 'user_controller.dart';

/// An implementation of the [UserController] that many Widgets can interact
/// with to get logged in user, logout user or listen to user changes.
///
/// Controllers glue Data Services to Flutter Widgets.
/// The [UserControllerImpl] uses the [SpringService] to get logged in user.
// /// [FirebaseMessaging] to get user's FCM token.
class UserControllerImpl extends ChangeNotifier implements UserController {
  // String? _fcmToken;
  MyUser? _user;

  // @override
  // String? get fcmToken => _fcmToken;

  @override
  MyUser? get user => _user;

  // @override
  // Future<String?> getFcmToken() async {
  //   _fcmToken = await FirebaseMessaging.instance.getToken();
  //
  //   return _fcmToken;
  // }

  @override
  Future<MyUser?> getUser() async {
    _user = await GetIt.I.get<SpringService>().getMongoUser();
    notifyListeners();

    return _user;
  }

  @override
  void logout() {
    _user = null;
    notifyListeners();
  }
}
