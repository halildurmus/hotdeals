import 'package:flutter/material.dart';

import '../helpers/context_extensions.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({required this.onPressed, required this.text, super.key});

  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(context.mq.size.width / 3, 40),
        maximumSize: Size(context.mq.size.width / 1.5, 40),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: context.textTheme.bodyText1!.copyWith(color: Colors.white),
      ),
    );
  }
}
