import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common_widgets/dialog_button.dart';
import '../../../../common_widgets/radio_item.dart';
import '../../../../helpers/context_extensions.dart';
import '../theme_mode_controller.dart';

class AppThemeDialog extends ConsumerWidget {
  const AppThemeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioItem<ThemeMode>(
              onTap: () => ref
                  .read(themeModeControllerProvider.notifier)
                  .changeThemeMode(ThemeMode.system),
              leading: const Icon(Icons.brightness_auto, size: 30),
              onChanged: ref
                  .read(themeModeControllerProvider.notifier)
                  .changeThemeMode,
              providerValue: themeMode,
              radioValue: ThemeMode.system,
              text: context.l.system,
            ),
            RadioItem<ThemeMode>(
              onTap: () => ref
                  .read(themeModeControllerProvider.notifier)
                  .changeThemeMode(ThemeMode.light),
              leading: const Icon(Icons.light_mode, size: 30),
              onChanged: ref
                  .read(themeModeControllerProvider.notifier)
                  .changeThemeMode,
              providerValue: themeMode,
              radioValue: ThemeMode.light,
              text: context.l.light,
            ),
            RadioItem<ThemeMode>(
              onTap: () => ref
                  .read(themeModeControllerProvider.notifier)
                  .changeThemeMode(ThemeMode.dark),
              leading: const Icon(Icons.dark_mode, size: 30),
              onChanged: ref
                  .read(themeModeControllerProvider.notifier)
                  .changeThemeMode,
              providerValue: themeMode,
              radioValue: ThemeMode.dark,
              text: context.l.dark,
            ),
            const SizedBox(height: 15),
            DialogButton(
              onPressed: Navigator.of(context).pop,
              text: context.l.ok,
            ),
          ],
        ),
      ),
    );
  }
}
