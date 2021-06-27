import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../chat/blocked_users.dart';
import '../chat/message_arguments.dart';
import '../chat/message_screen.dart';
import '../models/current_route.dart';
import '../models/my_user.dart';
import '../profile/profile.dart';
import '../settings/settings.view.dart';
import '../settings/settings_controller.dart';
import '../sign_in/auth_widget.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(
      RouteSettings routeSettings,
      AsyncSnapshot<MyUser?> userSnapshot,
      SettingsController settingsController) {
    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (BuildContext context) {
        switch (routeSettings.name) {
          case BlockedUsers.routeName:
            return const BlockedUsers();
          case MessageScreen.routeName:
            {
              final MessageArguments args =
                  routeSettings.arguments! as MessageArguments;

              GetIt.I
                  .get<CurrentRoute>()
                  .updateRouteName(MessageScreen.routeName);
              GetIt.I.get<CurrentRoute>().updateMessageArguments(args);

              return MessageScreen(docId: args.docId, user2: args.user2);
            }
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
}
