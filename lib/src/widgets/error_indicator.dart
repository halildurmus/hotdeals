import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    this.icon,
    this.iconColor,
    this.iconSize = 120,
    this.message,
    this.onTryAgain,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    required this.title,
    this.tryAgainText,
    Key? key,
  }) : super(key: key);

  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final String? message;
  final VoidCallback? onTryAgain;
  final EdgeInsets padding;
  final String title;
  final String? tryAgainText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon!, color: iconColor, size: iconSize),
            if (icon != null) const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            if (message != null) const SizedBox(height: 16),
            if (message != null)
              Text(
                message!,
                style: textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            if (onTryAgain != null) const SizedBox(height: 32),
            if (onTryAgain != null)
              ElevatedButton.icon(
                onPressed: onTryAgain,
                icon: const Icon(Icons.refresh),
                label: Text(
                  tryAgainText ?? AppLocalizations.of(context)!.tryAgain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
