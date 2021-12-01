import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class LocalizationUtil {
  static Widget getLanguageImage(Locale locale) {
    final assetName = languageImages[locale] ?? assetEnglish;

    return SvgPicture.asset(assetName);
  }

  static String getLanguageName(BuildContext context, Locale locale) {
    final languageNames = <Locale, String>{
      localeEnglish: AppLocalizations.of(context)!.english,
      localeTurkish: AppLocalizations.of(context)!.turkish,
    };

    return languageNames[locale] ?? AppLocalizations.of(context)!.english;
  }
}
