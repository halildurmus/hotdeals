import 'package:flutter/material.dart';

class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    required this.leading,
    required this.onTap,
    required this.title,
    Key? key,
    this.hasNavigation = true,
    this.subtitle,
  }) : super(key: key);

  final bool hasNavigation;
  final Widget leading;
  final VoidCallback onTap;
  final String? subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        dense: true,
        horizontalTitleGap: 0,
        leading: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 24, maxWidth: 24),
          child: leading,
        ),
        title: Text(
          title,
          style: textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing:
            hasNavigation ? const Icon(Icons.chevron_right, size: 30) : null,
      ),
    );
  }
}
