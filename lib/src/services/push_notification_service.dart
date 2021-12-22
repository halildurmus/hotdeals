import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/push_notification.dart';

typedef Json = Map<String, dynamic>;

/// An implementation of the [PushNotificationService] that many Widgets
/// can interact with to create, read and update notifications.
class PushNotificationService extends ChangeNotifier {
  late final _notificationController =
      StreamController<PushNotification>.broadcast();

  Stream<PushNotification> get notification => _notificationController.stream;

  int _unreadNotifications = 0;

  int get unreadNotifications => _unreadNotifications;

  late final Database _db;
  static const String _tableNotificationName = 'Notification';
  static const String _tableNotification = '''
  CREATE TABLE IF NOT EXISTS Notification (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        title_loc_key TEXT,
        title_loc_args TEXT,
        body TEXT,
        body_loc_key TEXT,
        body_loc_args TEXT,
        actor TEXT,
        verb TEXT,
        object TEXT,
        message TEXT,
        image TEXT,
        avatar TEXT,
        uid TEXT,
        is_read INTEGER,
        created_at TEXT
      );''';

  /// Opens the database and sets the database reference.
  Future<void> load() async {
    final path = join(await getDatabasesPath(), 'core.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(_tableNotification);
      },
    );
    _unreadNotifications = await getUnreadNotificationsCount() ?? 0;
  }

  /// Retrieves the unread notifications count.
  Future<int?> getUnreadNotificationsCount() async {
    final result = await _db.rawQuery(
        'SELECT COUNT (*) FROM $_tableNotificationName WHERE is_read = 0');

    return Sqflite.firstIntValue(result);
  }

  /// Inserts the notification into the database.
  Future<void> insert(PushNotification notification) async {
    // Insert the record into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same record is inserted twice.
    //
    // In this case, replace any previous data.
    final id = await _db.insert(
      _tableNotificationName,
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _unreadNotifications++;
    _notificationController.add(notification..id = id);
    notifyListeners();
  }

  /// Retrieves all notifications sorted by `created_at`.
  Future<List<PushNotification>> getAll({int? limit, int? offset}) async {
    final List<Json> maps = await _db.query(
      _tableNotificationName,
      orderBy: 'created_at DESC',
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid],
      limit: limit,
      offset: offset,
    );

    return List<PushNotification>.generate(
      maps.length,
      (i) => PushNotification.fromMap(maps[i]),
    );
  }

  /// Marks the notifications as read using given [ids].
  Future<void> markAsRead(List<int> ids) async {
    await _db.update(
      _tableNotificationName,
      {'is_read': 1},
      where: 'id IN (${ids.join(', ')})',
    );

    _unreadNotifications -= ids.length;
    notifyListeners();
  }

  /// Marks the notifications as unread using given [ids].
  Future<void> markAsUnread(List<int> ids) async {
    await _db.update(
      _tableNotificationName,
      {'is_read': 0},
      where: 'id IN (${ids.join(', ')})',
    );

    _unreadNotifications += ids.length;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationController.close();
    super.dispose();
  }
}
