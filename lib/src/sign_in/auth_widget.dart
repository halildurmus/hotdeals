import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../home/home.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
class AuthWidget extends StatelessWidget {
  const AuthWidget({Key? key, required this.userSnapshot}) : super(key: key);

  final AsyncSnapshot<MyUser?> userSnapshot;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget buildCircularProgressIndicator() {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );
    }

    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        final Future<MyUser?> userFuture =
            Provider.of<UserControllerImpl>(context, listen: false).getUser();

        return FutureBuilder<MyUser?>(
          future: userFuture,
          builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
            if (snapshot.hasData) {
              final MyUser user = snapshot.data!;

              // TODO(halildurmus): Get rid all of this once migrated to flutter_riverpod package.
              return FutureBuilder<String?>(
                future: FirebaseMessaging.instance.getToken(),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.hasData) {
                    final String fcmToken = snapshot.data!;

                    if (!user.fcmTokens!.contains(fcmToken)) {
                      return FutureBuilder<MyUser>(
                        future: GetIt.I
                            .get<SpringService>()
                            .addFcmToken(userId: user.id!, fcmToken: fcmToken),
                        builder: (BuildContext context,
                            AsyncSnapshot<MyUser> snapshot) {
                          if (snapshot.hasData) {
                            Provider.of<UserControllerImpl>(context,
                                    listen: false)
                                .getUser();

                            return const HomeScreen();
                          } else if (snapshot.hasError) {
                            print(snapshot.error);
                            print(snapshot.stackTrace);

                            return const HomeScreen();
                          }

                          return buildCircularProgressIndicator();
                        },
                      );
                    }

                    return const HomeScreen();
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    print(snapshot.stackTrace);

                    return const HomeScreen();
                  }

                  return buildCircularProgressIndicator();
                },
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              print(snapshot.stackTrace);

              return const HomeScreen();
            }

            return buildCircularProgressIndicator();
          },
        );
      } else if (userSnapshot.hasError) {
        print(userSnapshot.error);
        print(userSnapshot.stackTrace);

        return const Scaffold(body: Center(child: Text('An error occurred!')));
      }
    }

    return const HomeScreen();
  }
}
