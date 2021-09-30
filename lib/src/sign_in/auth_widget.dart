import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hotdeals/src/widgets/error_indicator.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

import '../home/home.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
class AuthWidget extends StatelessWidget with UiLoggy {
  const AuthWidget({Key? key, required this.userSnapshot}) : super(key: key);

  final AsyncSnapshot<MyUser?> userSnapshot;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Future<void> _saveFcmTokenToDatabase(String token) async {
      final String userId = context.read<UserControllerImpl>().user!.id!;

      await GetIt.I
          .get<SpringService>()
          .addFcmToken(userId: userId, fcmToken: token);

      await context.read<UserControllerImpl>().getUser();
    }

    Widget buildCircularProgressIndicator() {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );
    }

    Widget buildErrorWidget() {
      return Scaffold(
        body: ErrorIndicator(
          icon: Icons.wifi,
          title: AppLocalizations.of(context)!.noConnection,
          message: AppLocalizations.of(context)!.checkYourInternet,
          onTryAgain: () => build(context),
        ),
      );
    }

    if (userSnapshot.hasData) {
      final Future<MyUser?> userFuture =
          Provider.of<UserControllerImpl>(context, listen: false).getUser();

      return FutureBuilder<MyUser?>(
        future: userFuture,
        builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
          if (snapshot.hasData) {
            loggy.info(snapshot.data);
            // Gets the token each time the user logs in.
            FirebaseMessaging.instance.getToken().then((String? token) async {
              // Saves the initial token to the database.
              await _saveFcmTokenToDatabase(token!);

              // Any time the token refreshes, store this in the database too.
              FirebaseMessaging.instance.onTokenRefresh
                  .listen(_saveFcmTokenToDatabase);
            });

            return const HomeScreen();
          } else if (snapshot.hasError) {
            return const HomeScreen();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return buildErrorWidget();
          }

          return buildCircularProgressIndicator();
        },
      );
    }

    return const HomeScreen();
  }
}
