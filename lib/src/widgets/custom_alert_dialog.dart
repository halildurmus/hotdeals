import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../utils/localization_util.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    required this.title,
    Key? key,
    this.cancelActionText,
    this.content,
    this.defaultActionText,
  }) : super(key: key);

  final String? cancelActionText;
  final String? content;
  final String? defaultActionText;
  final String title;

  Future<bool?> show(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => this,
      );

  Widget _buildCancelButton(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(false),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
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
    );
  }

  Widget _buildDefaultButton(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.only(left: cancelActionText != null ? 8 : 0),
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: BorderSide(color: theme.primaryColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Text(
            defaultActionText ?? l(context).ok,
            style: textTheme.bodyText1!.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;

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
          mainAxisAlignment: cancelActionText == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            if (cancelActionText != null) ...[
              Expanded(child: _buildCancelButton(context)),
              Expanded(child: _buildDefaultButton(context)),
            ] else
              SizedBox(
                width: width / 2.5,
                child: _buildDefaultButton(context),
              )
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
