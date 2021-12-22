import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'no_internet.dart';
import 'services/connection_service.dart';
import 'widgets/offline_builder.dart';

Widget buildOfflineBuilder(BuildContext context, Widget? child) =>
    OfflineBuilder(
      connectionService: GetIt.I.get<ConnectionService>(),
      connectivityBuilder: (context, isConnected, child) =>
          isConnected ? child : const NoInternet(),
      errorBuilder: (context) => const NoInternet(),
      child: child,
    );
