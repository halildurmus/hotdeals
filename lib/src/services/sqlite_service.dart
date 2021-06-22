import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class SQLiteService<T> extends ChangeNotifier {
  int unreadNotifications = 0;

  /// Opens the database and sets the database reference.
  Future<void> load();

  /// Calculates the unread notifications count.
  Future<int> calculateUnreadNotifications();

  /// Inserts the record into the database.
  Future<void> insert(T t);

  /// Retrieves all the records from the table.
  Future<List<T>> getAll();

  /// Updates the record in the database.
  Future<void> update(T t);

  /// Deletes the record from the database.
  Future<void> delete(int id);

  /// Deletes all records from the database.
  Future<void> deleteAll();
}
