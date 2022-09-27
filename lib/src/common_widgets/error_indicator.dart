import 'package:flutter/material.dart';

import '../helpers/context_extensions.dart';

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
    super.key,
  });

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
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon!,
                color: iconColor ??
                    (context.isLightMode ? context.t.primaryColor : null),
                size: iconSize,
              ),
              const SizedBox(height: 16)
            ],
            Text(
              title,
              style: context.textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: context.textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ],
            if (onTryAgain != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onTryAgain,
                icon: Icon(tryAgainIcon),
                label: Text(
                  tryAgainText ?? context.l.tryAgain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoConnectionError extends StatelessWidget {
  const NoConnectionError({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ErrorIndicator(
      onTryAgain: onPressed,
      icon: Icons.wifi,
      title: context.l.noConnection,
      message: context.l.checkYourInternet,
    );
  }
}

class SomethingWentWrongError extends StatelessWidget {
  const SomethingWentWrongError({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.l.somethingWentWrong, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Icon(Icons.refresh, size: 16),
          ],
        ),
      ),
    );
  }
}
