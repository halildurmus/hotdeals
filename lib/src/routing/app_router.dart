import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../chat/blocked_users.dart';
import '../chat/message_arguments.dart';
import '../chat/message_screen.dart';
import '../models/current_route.dart';
import '../models/my_user.dart';
import '../profile/profile.dart';
import '../settings/settings.controller.dart';
import '../settings/settings.view.dart';
import '../sign_in/auth_widget.dart';

class AppRouter {
  static Route? onGenerateRoute(
    RouteSettings routeSettings,
    AsyncSnapshot<MyUser?> userSnapshot,
    SettingsController settingsController,
  ) =>
      MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          switch (routeSettings.name) {
            case BlockedUsers.routeName:
              return const BlockedUsers();
            case MessageScreen.routeName:
              final args = routeSettings.arguments! as MessageArguments;
              GetIt.I.get<CurrentRoute>().routeName = MessageScreen.routeName;
              GetIt.I.get<CurrentRoute>().messageArguments = args;

              return MessageScreen(docId: args.docId, user2: args.user2);
            case Profile.routeName:
              return const Profile();
            case SettingsView.routeName:
              return SettingsView(controller: settingsController);
            default:
              return AuthWidget(userSnapshot: userSnapshot);
          }
        },
      );
}
