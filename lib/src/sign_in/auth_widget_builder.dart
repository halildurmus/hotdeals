import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/auth_service.dart';

/// Used to create user-dependent objects that need to be accessible by all
/// src.widgets.
/// This src.widgets should live above the [MaterialApp].
/// See [AuthWidget], a descendant widget that consumes the snapshot generated
/// by this builder.
class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({Key? key, required this.builder}) : super(key: key);

  final Widget Function(BuildContext, AsyncSnapshot<MyUser?>) builder;

  @override
  Widget build(BuildContext context) {
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<MyUser?>(
      stream: authService.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
        final MyUser? user = snapshot.data;
        print('user: $user');

        return MultiProvider(
          providers: <SingleChildStatelessWidget>[
            Provider<MyUser?>.value(value: user),
            ChangeNotifierProvider<UserControllerImpl>(
              create: (_) => UserControllerImpl(),
            ),
          ],
          child: builder(context, snapshot),
        );
      },
    );
  }
}
