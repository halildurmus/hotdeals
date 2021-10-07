import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/push_notification.dart';
import '../services/sqlite_service.dart';

/// An abstract class that many Widgets can interact with to create, read and
/// update notifications.
abstract class PushNotificationService extends SQLiteService<PushNotification>
    with ChangeNotifier {
  int unreadNotifications = 0;
}
