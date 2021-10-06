import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    Key? key,
    required this.title,
    this.content,
    this.cancelActionText,
    this.defaultActionText,
  }) : super(key: key);

  final String title;
  final String? content;
  final String? cancelActionText;
  final String? defaultActionText;

  Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => this,
    );
  }

  Widget _buildContent(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final double width = MediaQuery.of(context).size.width;
    final double buttonWidth = (width - 32 - 48) / 2 - 8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (content != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              content!,
              textAlign: TextAlign.center,
              style: textTheme.bodyText1,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (cancelActionText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: buttonWidth,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: theme.primaryColor),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Text(
                        cancelActionText!,
                        style: textTheme.bodyText1!.copyWith(
                          color: theme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: cancelActionText != null ? 8 : 0),
              child: SizedBox(
                width: buttonWidth,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: theme.primaryColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Text(
                      defaultActionText ?? AppLocalizations.of(context)!.ok,
                      style: textTheme.bodyText1!.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
        ),
        content: _buildContent(context),
      ),
    );
  }
}
