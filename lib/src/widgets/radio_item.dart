import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RadioItem<V> extends StatelessWidget {
  const RadioItem({
    Key? key,
    required this.onChanged,
    required this.onTap,
    this.icon,
    this.iconPath,
    required this.providerValue,
    required this.radioValue,
    required this.text,
  }) : super(key: key);

  final void Function(V? value) onChanged;
  final VoidCallback onTap;
  final IconData? icon;
  final String? iconPath;
  final V providerValue;
  final V radioValue;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
          horizontalTitleGap: 4,
          leading: icon != null
              ? Icon(icon, size: 30)
              : SvgPicture.asset(iconPath!, height: 30, width: 30),
          title: Text(
            text,
            style: textTheme.bodyText1!.copyWith(
              fontWeight: providerValue == radioValue ? FontWeight.bold : null,
            ),
          ),
          trailing: Radio<V>(
            value: radioValue,
            groupValue: providerValue,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
