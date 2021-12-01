import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

import '../home/home.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/spring_service.dart';
import '../utils/error_indicator_util.dart';
import '../utils/localization_util.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
class AuthWidget extends StatelessWidget with UiLoggy {
  const AuthWidget({Key? key, required this.userSnapshot}) : super(key: key);

  final AsyncSnapshot<MyUser?> userSnapshot;

  Widget buildCircularProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).appTitle),
      ),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      ),
    );
  }

  Widget buildErrorWidget(BuildContext context) {
    return Scaffold(
      body: ErrorIndicatorUtil.buildFirstPageError(
        context,
        onTryAgain: () => (context as Element).markNeedsBuild(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _saveFcmTokenToDatabase(String token) async {
      await GetIt.I.get<SpringService>().addFcmToken(fcmToken: token);
      await context.read<UserController>().getUser();
    }

    if (!userSnapshot.hasData) {
      return const HomeScreen();
    }

    final userFuture =
        Provider.of<UserController>(context, listen: false).getUser();

    return FutureBuilder<MyUser?>(
      future: userFuture,
      builder: (context, snapshot) {
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
          loggy.error(snapshot.error);
          return const HomeScreen();
        } else if (snapshot.connectionState == ConnectionState.done) {
          return buildErrorWidget(context);
        }

        return buildCircularProgressIndicator(context);
      },
    );
  }
}
