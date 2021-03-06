import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({required this.child, Key? key}) : super(key: key);

  final Widget child;

  Widget _buildDialog() => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) => _buildDialog();
}
