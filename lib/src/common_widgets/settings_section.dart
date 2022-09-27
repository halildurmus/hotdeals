import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.children,
    required this.title,
    super.key,
  });

  final List<Widget> children;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),
          ),
        ),
        ...children,
      ],
    );
  }
}
