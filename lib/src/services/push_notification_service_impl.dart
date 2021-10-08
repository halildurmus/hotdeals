import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/push_notification.dart';
import '../services/push_notification_service.dart';

typedef Json = Map<String, dynamic>;

/// An implementation of the [PushNotificationService] that many Widgets
/// can interact with to create, read and update notifications.
class PushNotificationServiceImpl extends ChangeNotifier
    implements PushNotificationService {
  @override
  int unreadNotifications = 0;

  late Database _db;
  static const String tableNotificationName = 'Notification';
  static const String tableNotification = '''
  CREATE TABLE IF NOT EXISTS Notification (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        body TEXT,
        actor TEXT,
        verb TEXT,
        object TEXT,
        message TEXT,
        uid TEXT,
        is_read INTEGER,
        created_at TEXT
      );''';

  /// Opens the database and sets the database reference.
  @override
  Future<void> load() async {
    final String path = join(await getDatabasesPath(), 'core.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(tableNotification);
      },
    );
  }

  /// Inserts the notification into the database.
  @override
  Future<void> insert(PushNotification notification) async {
    // Insert the record into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same record is inserted twice.
    //
    // In this case, replace any previous data.
    await _db.insert(
      tableNotificationName,
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    unreadNotifications++;
    notifyListeners();
  }

  /// Retrieves all notifications sorted by `created_at` from the database.
  @override
  Future<List<PushNotification>> getAll({int? limit, int? offset}) async {
    // Query the table for all the records.
    final List<Json> maps = await _db.query(
      tableNotificationName,
      orderBy: 'created_at DESC',
      where: 'uid = ?',
      whereArgs: [FirebaseAuth.instance.currentUser?.uid],
      limit: limit,
      offset: offset,
    );

    // Convert the List<Json> into a List<Notification>.
    return List<PushNotification>.generate(
      maps.length,
      (int i) => PushNotification.fromMap(maps[i]),
    );
  }

  /// Updates the given notification.
  @override
  Future<void> update(PushNotification notification) async {
    await _db.update(
      tableNotificationName,
      notification.toMap(),
      // Ensure that the record has a matching id.
      where: 'id = ?',
      // Pass the notification's id as a whereArg to prevent SQL injection.
      whereArgs: [notification.id],
    );

    if (notification.isRead) {
      unreadNotifications--;
    }

    notifyListeners();
  }

  /// Deletes the notification from the database.
  @override
  Future<void> delete(int id) async {
    await _db.delete(
      tableNotificationName,
      // Use a `where` clause to delete a specific record.
      where: 'id = ?',
      // Pass the record's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );

    notifyListeners();
  }

  /// Deletes all notifications from the database.
  @override
  Future<void> deleteAll() async {
    await _db.delete(tableNotificationName);

    notifyListeners();
  }
}
