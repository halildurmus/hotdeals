import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/auth_service.dart';

/// Used to create user-dependent objects that need to be accessible by all
/// widgets.
/// This widgets should live above the [MaterialApp].
/// See [AuthWidget], a descendant widget that consumes the snapshot generated
/// by this builder.
class AuthWidgetBuilder extends StatelessWidget with UiLoggy {
  const AuthWidgetBuilder({Key? key, required this.builder}) : super(key: key);

  final Widget Function(BuildContext, AsyncSnapshot<MyUser?>) builder;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<MyUser?>(
      stream: authService.onAuthStateChanged,
      builder: (context, snapshot) {
        final MyUser? user = snapshot.data;
        loggy.info('User uid: ${user?.uid}');

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<UserController>(
              create: (_) => UserController(),
            ),
          ],
          child: builder(context, snapshot),
        );
      },
    );
  }
}
