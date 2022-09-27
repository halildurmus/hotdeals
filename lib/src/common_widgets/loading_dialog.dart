import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/context_extensions.dart';

final loadingDialogProvider =
    Provider<LoadingDialog>((ref) => const LoadingDialog());

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

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

  Future<void> showLoadingDialog(BuildContext context) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: _buildAlertDialog,
    );
  }

  @override
  Widget build(BuildContext context) => _buildAlertDialog(context);
}
