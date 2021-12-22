import 'package:flutter/material.dart';

import '../utils/localization_util.dart';
import 'custom_alert_dialog.dart';

class SignInDialog extends StatelessWidget {
  const SignInDialog({Key? key}) : super(key: key);

  Widget _buildSignInDialog(BuildContext context) => CustomAlertDialog(
        title: l(context).youNeedToSignIn,
        content: l(context).youNeedToSignInToPerform,
      );

  Future<bool?> showSignInDialog(BuildContext context) => showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: _buildSignInDialog,
      );

  @override
  Widget build(BuildContext context) => _buildSignInDialog(context);
}
