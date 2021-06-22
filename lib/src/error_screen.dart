import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'models/categories.dart';
import 'models/stores.dart';
import 'widgets/loading_dialog.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, required this.onTap}) : super(key: key);

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hotdeals'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('An error occurred while fetching some data.'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                GetIt.I.get<LoadingDialog>().showLoadingDialog(context);
                await onTap();
                Navigator.of(context).pop();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
