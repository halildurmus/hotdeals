import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/exception_alert_dialog.dart';
import '../widgets/social_button.dart';
import 'sign_in_manager.dart';

class SignInPageBuilder extends StatelessWidget {
  const SignInPageBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) =>
            Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, SignInManager manager, __) => SignInPage._(
              isLoading: isLoading.value,
              manager: manager,
            ),
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage._({Key? key, required this.isLoading, required this.manager})
      : super(key: key);

  final SignInManager manager;
  final bool isLoading;

  Future<void> showSignInError(
      BuildContext context, PlatformException exception) async {
    await ExceptionAlertDialog(
      title: AppLocalizations.of(context)!.signInFailed,
      exception: exception,
    ).show(context);
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      await manager.signInWithFacebook();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        await showSignInError(context, e);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        await showSignInError(context, e);
      }
    }
  }

  Widget buildSignIn(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)!.signIn,
            style: textTheme.headline2!.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50.0),
          SocialButton(
            backgroundColor: const Color.fromRGBO(63, 91, 150, 1),
            icon: FontAwesomeIcons.facebook,
            text: AppLocalizations.of(context)!.continueWithFacebook,
            onPressed: () => signInWithFacebook(context),
            height: 48.0,
          ),
          const SizedBox(height: 10.0),
          SocialButton(
            backgroundColor: const Color.fromRGBO(66, 133, 244, 1),
            icon: FontAwesomeIcons.google,
            text: AppLocalizations.of(context)!.continueWithGoogle,
            onPressed: () => signInWithGoogle(context),
            height: 48.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.signIn),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            )
          : buildSignIn(context),
    );
  }
}
