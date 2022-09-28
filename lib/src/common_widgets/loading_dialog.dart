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
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(context.l.loading),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildAlertDialog(context);
}
