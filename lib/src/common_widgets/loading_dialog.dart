import 'package:flutter/material.dart';

import '../helpers/context_extensions.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  void showLoadingDialog(BuildContext context) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: _buildAlertDialog,
    );
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: context.mq.size.width * .25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        spacing: 20,
        children: [
          const CircularProgressIndicator.adaptive(strokeWidth: 2),
          Text(context.l.loading, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildAlertDialog(context);
}
