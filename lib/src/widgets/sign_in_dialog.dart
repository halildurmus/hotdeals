import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'custom_alert_dialog.dart';

class SignInDialog extends StatelessWidget {
  const SignInDialog({Key? key}) : super(key: key);

  Widget _buildSignInDialog(BuildContext context) {
    return CustomAlertDialog(
      title: AppLocalizations.of(context)!.youNeedToSignIn,
      content: AppLocalizations.of(context)!.youNeedToSignInToPerform,
    );
  }

  Future<bool?> showSignInDialog(BuildContext context) {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) => _buildSignInDialog(ctx),
    );
  }

  @override
  Widget build(BuildContext context) => _buildSignInDialog(context);
}
