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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
