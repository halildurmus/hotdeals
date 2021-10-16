import 'package:flutter/material.dart';

class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    Key? key,
    this.hasNavigation = true,
    required this.leading,
    required this.onTap,
    this.subtitle,
    required this.title,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
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
      ),
    );
  }
}
