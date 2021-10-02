import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import 'utils/error_indicator_util.dart';
import 'widgets/loading_dialog.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, required this.onTap}) : super(key: key);

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: ErrorIndicatorUtil.buildFirstPageError(
        context,
        onTryAgain: () async {
          GetIt.I.get<LoadingDialog>().showLoadingDialog(context);
          await onTap();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
