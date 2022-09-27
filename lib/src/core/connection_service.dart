import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectionServiceProvider = Provider<ConnectionService>(
    (ref) => throw UnimplementedError(),
    name: 'ConnectionServiceProvider');

class ConnectionService {
  // Returns the current connection status.
  bool hasConnection = false;

  // Creates a StreamController for tracking connection changes.
  StreamController<bool> connectionChangeController =
      StreamController<bool>.broadcast();

  // Creates an instance of Connectivity from package:flutter_connectivity.
  final Connectivity _connectivity = Connectivity();

  // Hooks into flutter_connectivity's Stream to listen for changes
  // and checks the connection status out of the gate.
  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream<bool> get connectionChange => connectionChangeController.stream;

  // A clean up method to close our StreamController. Because this is meant to
  // exist through the entire application life cycle this isn't really an issue.
  void dispose() => connectionChangeController.close();

  // flutter_connectivity's listener.
  void _connectionChange(ConnectivityResult result) => checkConnection();

  // Checks if there is a connection.
  Future<bool> checkConnection() async {
    final previousConnection = hasConnection;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    // Sends out an update to all listeners if the connection status changed.
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}
