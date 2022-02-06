import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../firebase_messaging_listener.dart';
import '../home/home.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/api_repository.dart';
import '../utils/error_indicator_util.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
class AuthWidget extends StatefulWidget {
  const AuthWidget({required this.userSnapshot, Key? key}) : super(key: key);

  final AsyncSnapshot<MyUser?> userSnapshot;

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> with UiLoggy {
  late Future<MyUser?> _userFuture;

  Future<void> _saveFCMTokenToDatabase(String token) async {
    final androidDeviceInfo = GetIt.I.get<AndroidDeviceInfo>();
    final deviceId = androidDeviceInfo.androidId!;
    await GetIt.I
        .get<APIRepository>()
        .addFCMToken(deviceId: deviceId, token: token);
    await context.read<UserController>().getUser();
  }

  Widget buildCircularProgressIndicator() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      ),
    );
  }

  Widget buildErrorWidget() => Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: ErrorIndicatorUtil.buildFirstPageError(
          context,
          onTryAgain: () => setState(() {}),
        ),
      );

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
          // Gets the FCM token each time the user logs in.
          FirebaseMessaging.instance.getToken().then((token) async {
            await _saveFCMTokenToDatabase(token!);
            // Any time the token refreshes, store it in the database.
            FirebaseMessaging.instance.onTokenRefresh
                .listen(_saveFCMTokenToDatabase);
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
