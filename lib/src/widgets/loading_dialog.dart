import 'package:flutter/material.dart';

import '../utils/localization_util.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  Widget _buildAlertDialog(BuildContext context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l(context).loading),
          ],
        ),
      );

  Future<void> showLoadingDialog(BuildContext context) => showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: _buildAlertDialog,
      );

  @override
  Widget build(BuildContext context) => _buildAlertDialog(context);
}
