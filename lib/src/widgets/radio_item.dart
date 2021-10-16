import 'package:flutter/material.dart';

class RadioItem<V> extends StatelessWidget {
  const RadioItem({
    Key? key,
    required this.leading,
    required this.onChanged,
    required this.onTap,
    required this.providerValue,
    required this.radioValue,
    required this.text,
  }) : super(key: key);

  final Widget leading;
  final void Function(V? value) onChanged;
  final VoidCallback onTap;
  final V providerValue;
  final V radioValue;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        horizontalTitleGap: 4,
        leading: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 30, maxWidth: 30),
          child: leading,
        ),
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
    );
  }
}
