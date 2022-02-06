import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'constants.dart';
import 'utils/error_indicator_util.dart';
import 'widgets/loading_dialog.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.onTap, Key? key}) : super(key: key);

  final Function(BuildContext ctx) onTap;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: ErrorIndicatorUtil.buildFirstPageError(
          context,
          onTryAgain: () {
            GetIt.I.get<LoadingDialog>().showLoadingDialog(context);
            onTap(context);
          },
        ),
      );
}
