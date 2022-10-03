import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common_widgets/settings_list_item.dart';
import '../../../common_widgets/settings_section.dart';
import '../../../core/package_info_provider.dart';
import '../../../helpers/context_extensions.dart';
import '../../../l10n/localization_helpers.dart';
import 'locale_controller.dart';
import 'theme_mode_controller.dart';
import 'widgets/app_language_dialog.dart';
import 'widgets/app_theme_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final packageInfo = ref.read(packageInfoProvider);
    final appName = packageInfo.appName;
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.settings),
      ),
      body: Column(
        children: [
          SettingsSection(
            title: context.l.general,
            children: [
              SettingsListItem(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AppLanguageDialog(),
                ),
                leading: SvgPicture.asset(assetNameFromLocale(locale)),
                title: context.l.language,
                subtitle: localeNameFromLocale(context, locale),
              ),
              SettingsListItem(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AppThemeDialog(),
                ),
                leading: const Icon(Icons.settings_brightness),
                title: context.l.theme,
                subtitle: themeModeTextFromThemeMode(context, themeMode),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '$appName v$version ($buildNumber)',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          )
        ],
      ),
    );
  }
}
