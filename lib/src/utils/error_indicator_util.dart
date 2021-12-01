import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/error_indicator.dart';

/// A static class that contains useful functions to display error indicator
/// widgets.
class ErrorIndicatorUtil {
  static ErrorIndicator buildFirstPageError(
    BuildContext context, {
    required VoidCallback onTryAgain,
  }) {
    return ErrorIndicator(
      icon: Icons.wifi,
      title: AppLocalizations.of(context)!.noConnection,
      message: AppLocalizations.of(context)!.checkYourInternet,
      onTryAgain: onTryAgain,
    );
  }

  static Widget buildNewPageError(
    BuildContext context, {
    required VoidCallback onTryAgain,
  }) {
    return InkWell(
      onTap: onTryAgain,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.somethingWentWrong,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Icon(Icons.refresh, size: 16),
          ],
        ),
      ),
    );
  }
}
