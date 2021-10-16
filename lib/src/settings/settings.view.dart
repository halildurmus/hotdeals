import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hotdeals/src/widgets/settings_section.dart';

import '../constants.dart';
import '../widgets/radio_item.dart';
import '../widgets/settings_list_item.dart';
import 'settings.controller.dart';
import 'settings_dialog.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const String routeName = '/settings';

  final SettingsController controller;

  Widget _getLanguageImage(Locale locale) {
    late String svgLocation;
    if (locale == kLocaleTurkish) {
      svgLocation = kTurkishSvg;
    } else {
      svgLocation = kEnglishSvg;
    }

    return SvgPicture.asset(svgLocation);
  }

  String _getLanguageName(BuildContext context, Locale locale) {
    if (locale == kLocaleTurkish) {
      return AppLocalizations.of(context)!.turkish;
    }

    return AppLocalizations.of(context)!.english;
  }

  String _getThemeName(BuildContext context, ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark) {
      return AppLocalizations.of(context)!.dark;
    } else if (themeMode == ThemeMode.light) {
      return AppLocalizations.of(context)!.light;
    }

    return AppLocalizations.of(context)!.system;
  }

  Future<void> _changeLanguage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;

    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(VoidCallback) setState) {
            return SettingsDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioItem<Locale>(
                    onTap: () => controller.updateLocale(kLocaleEnglish),
                    onChanged: controller.updateLocale,
                    providerValue: controller.locale,
                    radioValue: kLocaleEnglish,
                    leading: SvgPicture.asset('assets/icons/en.svg'),
                    text: AppLocalizations.of(context)!.english,
                  ),
                  RadioItem<Locale>(
                    onTap: () => controller.updateLocale(kLocaleTurkish),
                    onChanged: controller.updateLocale,
                    providerValue: controller.locale,
                    radioValue: kLocaleTurkish,
                    leading: SvgPicture.asset('assets/icons/tr.svg'),
                    text: AppLocalizations.of(context)!.turkish,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(deviceWidth, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: textTheme.bodyText1!.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _changeAppTheme(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;

    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SettingsDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioItem<ThemeMode>(
                onTap: () => controller.updateThemeMode(ThemeMode.system),
                onChanged: controller.updateThemeMode,
                providerValue: controller.themeMode,
                radioValue: ThemeMode.system,
                leading: const Icon(Icons.brightness_auto, size: 30),
                text: AppLocalizations.of(context)!.system,
              ),
              RadioItem<ThemeMode>(
                onTap: () => controller.updateThemeMode(ThemeMode.light),
                onChanged: controller.updateThemeMode,
                providerValue: controller.themeMode,
                radioValue: ThemeMode.light,
                leading: const Icon(Icons.light_mode, size: 30),
                text: AppLocalizations.of(context)!.light,
              ),
              RadioItem<ThemeMode>(
                onTap: () => controller.updateThemeMode(ThemeMode.dark),
                onChanged: controller.updateThemeMode,
                providerValue: controller.themeMode,
                radioValue: ThemeMode.dark,
                leading: const Icon(Icons.dark_mode, size: 30),
                text: AppLocalizations.of(context)!.dark,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(deviceWidth, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: textTheme.bodyText1!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Column(
        children: [
          SettingsSection(
            title: AppLocalizations.of(context)!.general,
            children: [
              SettingsListItem(
                onTap: () => _changeLanguage(context),
                leading: _getLanguageImage(controller.locale),
                title: AppLocalizations.of(context)!.language,
                subtitle: _getLanguageName(context, controller.locale),
              ),
              SettingsListItem(
                onTap: () => _changeAppTheme(context),
                leading: const Icon(Icons.settings_brightness),
                title: AppLocalizations.of(context)!.theme,
                subtitle: _getThemeName(context, controller.themeMode),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
