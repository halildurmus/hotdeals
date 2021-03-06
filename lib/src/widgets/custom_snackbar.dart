import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  const CustomSnackBar({
    required this.text,
    Key? key,
    this.action,
    this.content,
    this.icon,
  }) : super(key: key);

  final SnackBarAction? action;
  final Widget? content;
  final Widget? icon;
  final String text;

  Widget _buildContent(BuildContext context) =>
      content ??
      Row(
        children: [
          if (icon != null) icon!,
          if (icon != null) const SizedBox(width: 8),
          _buildText(context),
        ],
      );

  Widget _buildText(BuildContext context) => Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyText2,
      );

  SnackBar buildSnackBar(BuildContext context) {
    final theme = Theme.of(context);

    return SnackBar(
      action: action,
      backgroundColor: theme.backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      content: _buildContent(context),
    );
  }

  @override
  Widget build(BuildContext context) => buildSnackBar(context);
}
