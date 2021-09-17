import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import 'widgets/loading_dialog.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, required this.onTap}) : super(key: key);

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.anErrorOccurredWhile),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                GetIt.I.get<LoadingDialog>().showLoadingDialog(context);
                await onTap();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
