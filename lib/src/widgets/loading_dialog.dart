import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(AppLocalizations.of(context)!.loading),
        ],
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) => _buildAlertDialog(ctx),
    );
  }

  @override
  Widget build(BuildContext context) => _buildAlertDialog(context);
}
