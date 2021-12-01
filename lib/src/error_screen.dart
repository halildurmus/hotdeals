import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'utils/error_indicator_util.dart';
import 'utils/localization_util.dart';
import 'widgets/loading_dialog.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, required this.onTap}) : super(key: key);

  final Function(BuildContext ctx) onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l(context).appTitle)),
      body: ErrorIndicatorUtil.buildFirstPageError(
        context,
        onTryAgain: () async {
          GetIt.I.get<LoadingDialog>().showLoadingDialog(context);
          onTap(context);
        },
      ),
    );
  }
}
