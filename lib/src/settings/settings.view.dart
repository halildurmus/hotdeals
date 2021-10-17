import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants.dart';
import '../widgets/radio_item.dart';
import '../widgets/settings_list_item.dart';
import '../widgets/settings_section.dart';
import 'settings.controller.dart';
import 'settings_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const String routeName = '/settings';

  final SettingsController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        _packageInfo = packageInfo;
      });
    });
  }

  Widget _buildAppInfoText() {
    final appName = _packageInfo!.appName;
    final version = _packageInfo!.version;
    final buildNumber = _packageInfo!.buildNumber;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text('$appName v$version ($buildNumber)',
          style: Theme.of(context).textTheme.bodyText2),
    );
  }

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
                    onTap: () => widget.controller.updateLocale(kLocaleEnglish),
                    onChanged: widget.controller.updateLocale,
                    providerValue: widget.controller.locale,
                    radioValue: kLocaleEnglish,
                    leading: SvgPicture.asset('assets/icons/en.svg'),
                    text: AppLocalizations.of(context)!.english,
                  ),
                  RadioItem<Locale>(
                    onTap: () => widget.controller.updateLocale(kLocaleTurkish),
                    onChanged: widget.controller.updateLocale,
                    providerValue: widget.controller.locale,
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
                onTap: () =>
                    widget.controller.updateThemeMode(ThemeMode.system),
                onChanged: widget.controller.updateThemeMode,
                providerValue: widget.controller.themeMode,
                radioValue: ThemeMode.system,
                leading: const Icon(Icons.brightness_auto, size: 30),
                text: AppLocalizations.of(context)!.system,
              ),
              RadioItem<ThemeMode>(
                onTap: () => widget.controller.updateThemeMode(ThemeMode.light),
                onChanged: widget.controller.updateThemeMode,
                providerValue: widget.controller.themeMode,
                radioValue: ThemeMode.light,
                leading: const Icon(Icons.light_mode, size: 30),
                text: AppLocalizations.of(context)!.light,
              ),
              RadioItem<ThemeMode>(
                onTap: () => widget.controller.updateThemeMode(ThemeMode.dark),
                onChanged: widget.controller.updateThemeMode,
                providerValue: widget.controller.themeMode,
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
                leading: _getLanguageImage(widget.controller.locale),
                title: AppLocalizations.of(context)!.language,
                subtitle: _getLanguageName(context, widget.controller.locale),
              ),
              SettingsListItem(
                onTap: () => _changeAppTheme(context),
                leading: const Icon(Icons.settings_brightness),
                title: AppLocalizations.of(context)!.theme,
                subtitle: _getThemeName(context, widget.controller.themeMode),
              ),
            ],
          ),
          if (_packageInfo != null) _buildAppInfoText(),
        ],
      ),
    );
  }
}
