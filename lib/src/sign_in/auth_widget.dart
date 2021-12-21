import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

import '../firebase_messaging_listener.dart';
import '../home/home.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/spring_service.dart';
import '../utils/error_indicator_util.dart';
import '../utils/localization_util.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
class AuthWidget extends StatefulWidget {
  const AuthWidget({Key? key, required this.userSnapshot}) : super(key: key);

  final AsyncSnapshot<MyUser?> userSnapshot;

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> with UiLoggy {
  late Future<MyUser?> _userFuture;

  Future<void> _saveFcmTokenToDatabase(String token) async {
    await GetIt.I.get<SpringService>().addFcmToken(fcmToken: token);
    await context.read<UserController>().getUser();
  }

  Widget buildCircularProgressIndicator() {
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

  Widget buildErrorWidget() {
    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).appTitle),
      ),
      body: ErrorIndicatorUtil.buildFirstPageError(
        context,
        onTryAgain: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.userSnapshot.hasData) {
      return const HomeScreen();
    }
    _userFuture = Provider.of<UserController>(context, listen: false).getUser();

    return FutureBuilder<MyUser?>(
      future: _userFuture,
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
          // Subscribes to Firebase Cloud Messaging.
          subscribeToFCM();

          return const HomeScreen();
        } else if (snapshot.hasError) {
          loggy.error(snapshot.error);
          return const HomeScreen();
        } else if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting) {
          return buildCircularProgressIndicator();
        } else {
          return buildErrorWidget();
        }
      },
    );
  }
}
