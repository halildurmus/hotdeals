import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'no_internet.dart';
import 'services/connection_service.dart';
import 'widgets/offline_builder.dart';

Widget buildOfflineBuilder(BuildContext context, Widget? child) {
  return OfflineBuilder(
    connectionService: GetIt.I.get<ConnectionService>(),
    connectivityBuilder: (
      BuildContext context,
      bool isConnected,
      Widget child,
    ) {
      return isConnected ? child : const NoInternet();
    },
    errorBuilder: (BuildContext context) => const NoInternet(),
    child: child,
  );
}
