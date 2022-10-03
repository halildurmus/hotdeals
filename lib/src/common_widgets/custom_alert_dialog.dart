import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../helpers/context_extensions.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    required this.title,
    this.cancelAction,
    this.cancelActionText,
    this.content,
    this.defaultAction,
    this.defaultActionText,
    super.key,
  });

  final void Function()? cancelAction;
  final String? cancelActionText;
  final String? content;
  final void Function()? defaultAction;
  final String? defaultActionText;
  final String title;

  Future<bool?> show(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => this,
      );

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: context.textTheme.titleLarge!,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (content != null) ...[
              Text(
                content!,
                style: context.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: cancelActionText == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (cancelActionText != null) ...[
                  _CancelButton(
                    onPressed: cancelAction,
                    title: cancelActionText!,
                  ),
                  const SizedBox(width: 15),
                  _DefaultButton(
                    onPressed: defaultAction,
                    title: defaultActionText ?? context.l.ok,
                  ),
                ] else
                  _DefaultButton(
                    onPressed: defaultAction,
                    title: defaultActionText ?? context.l.ok,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({this.onPressed, required this.title});

  final VoidCallback? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _DialogButton(onPressed: onPressed, title: title);
  }
}

class _DefaultButton extends StatelessWidget {
  const _DefaultButton({this.onPressed, required this.title});

  final VoidCallback? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _DialogButton(
      onPressed: onPressed,
      backgroundColor: context.t.primaryColor,
      textColor: Colors.white,
      title: title,
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.title,
    this.backgroundColor,
    this.onPressed,
    this.textColor,
  });

  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final Color? textColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        onPressed?.call();
        Navigator.of(context).pop(false);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        fixedSize: Size(context.mq.size.width / 3.2, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: context.t.primaryColor),
      ),
      child: Text(
        title,
        style: context.textTheme.bodyText1!.copyWith(
          color: textColor ?? context.t.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
