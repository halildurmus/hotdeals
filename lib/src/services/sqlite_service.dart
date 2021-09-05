import 'dart:async';

/// An abstract class that many Widgets can interact with to create, read and
/// update records.
abstract class SQLiteService<T> {
  /// Opens the database and sets the database reference.
  Future<void> load();

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
