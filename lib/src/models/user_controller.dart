import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'my_user.dart';

/// An abstract class that many Widgets can interact with to get logged in user,
/// logout user or listen to user changes.
abstract class UserController extends ChangeNotifier {
  // /// Returns the logged in user's FCM token.
  // String? get fcmToken;

  /// Returns the logged in user.
  MyUser? get user;

  // /// Loads the logged in user's FCM token from [FirebaseMessaging].
  // Future<String?> getFcmToken();

  /// Loads the logged in user's document from database.
  Future<MyUser?> getUser();

  /// Logs the user out of the system.
  void logout();
}
