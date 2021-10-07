import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    Key? key,
    this.hasNavigation = true,
    this.icon,
    this.image,
    required this.onTap,
    this.subtitle,
    required this.title,
  })  : assert(icon != null || image != null,
            'You need to specify either an icon or an image!'),
        super(key: key);

  final bool hasNavigation;
  final IconData? icon;
  final Widget? image;
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
          leading: icon != null
              ? Icon(icon, size: 25)
              : ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 25, maxWidth: 25),
                  child: image,
                ),
          title: Text(
            title,
            style: textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing:
              hasNavigation ? const Icon(LineIcons.angleRight, size: 25) : null,
        ),
      ),
    );
  }
}
