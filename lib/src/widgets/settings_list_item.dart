import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    Key? key,
    required this.onTap,
    required this.title,
    this.subtitle,
    this.hasNavigation = true,
    this.icon,
    this.image,
  })  : assert(icon != null || image != null,
            'You need to specify either an icon or an image!'),
        super(key: key);

  final VoidCallback onTap;
  final IconData? icon;
  final Widget? image;
  final String title;
  final String? subtitle;
  final bool hasNavigation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

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
