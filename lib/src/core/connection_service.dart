import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectionServiceProvider = Provider<ConnectionService>(
    (ref) => throw UnimplementedError(),
    name: 'ConnectionServiceProvider');

class ConnectionService {
  // Returns the current connection status.
  var hasConnection = false;

  // Creates a StreamController for tracking connection changes.
  final connectionChangeController = StreamController<bool>.broadcast();

  // Creates an instance of Connectivity from package:flutter_connectivity.
  final _connectivity = Connectivity();

  // Hooks into flutter_connectivity's Stream to listen for changes
  // and checks the connection status out of the gate.
  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream<bool> get connectionChange => connectionChangeController.stream;

  // flutter_connectivity's listener.
  void _connectionChange(ConnectivityResult result) => checkConnection();

  // Checks if there is a connection.
  Future<bool> checkConnection() async {
    // TODO(halildurmus): Get rid of this workaround
    // Sometimes the connectivity check will return true even though the device
    // is offline. I think this happens because the onConnectivityChanged callback
    // is triggered so fast that when this function does a lookup, the device is
    // still online. To fix this, I added a 1-second delay as a workaround.
    await Future<void>.delayed(const Duration(seconds: 1));
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

  // A clean up method to close our StreamController. Because this is meant to
  // exist through the entire application life cycle this isn't really an issue.
  void dispose() => connectionChangeController.close();
}
