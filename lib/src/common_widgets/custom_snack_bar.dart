import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/context_extensions.dart';

class CustomSnackBar extends StatelessWidget {
  const CustomSnackBar({
    required this.text,
    this.action,
    this.content,
    this.icon,
    super.key,
  });

  const CustomSnackBar.error({
    this.action,
    this.content,
    this.icon = const Icon(FontAwesomeIcons.circleExclamation, size: 20),
    this.text,
    super.key,
  });

  const CustomSnackBar.success({
    required this.text,
    this.action,
    this.content,
    this.icon = const Icon(FontAwesomeIcons.circleCheck, size: 20),
    super.key,
  });

  final SnackBarAction? action;
  final Widget? content;
  final Widget? icon;
  final String? text;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      BuildContext context) {
    final snackBar = _buildSnackBar(context);
    return context.showSnackBar(snackBar);
  }

  SnackBar _buildSnackBar(BuildContext context) {
    return SnackBar(
      action: action,
      backgroundColor: context.t.backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: content ??
          Row(
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                text ?? context.l.anErrorOccurred,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyText2,
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildSnackBar(context);
}
