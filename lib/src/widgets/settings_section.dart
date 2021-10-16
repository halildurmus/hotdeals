import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'settings_list_item.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    Key? key,
    required this.children,
    required this.title,
  }) : super(key: key);

  final List<SettingsListItem> children;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              color: isDarkMode ? null : Theme.of(context).primaryColorDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
