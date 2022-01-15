import 'package:flutter/material.dart';

import '../utils/localization_util.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    required this.title,
    this.icon,
    this.iconColor,
    this.iconSize = 120,
    this.message,
    this.onTryAgain,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.tryAgainIcon = Icons.refresh,
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
  final IconData tryAgainIcon;
  final String? tryAgainText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isLightMode = theme.brightness == Brightness.light;
    final _iconColor = iconColor ?? (isLightMode ? theme.primaryColor : null);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon!, color: _iconColor, size: iconSize),
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
                icon: Icon(tryAgainIcon),
                label: Text(
                  tryAgainText ?? l(context).tryAgain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
