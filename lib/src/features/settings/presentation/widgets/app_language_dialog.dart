import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common_widgets/dialog_button.dart';
import '../../../../common_widgets/radio_item.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../../l10n/localization_constants.dart';
import '../locale_controller.dart';

class AppLanguageDialog extends ConsumerWidget {
  const AppLanguageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioItem<Locale>(
              onTap: () => ref
                  .read(localeControllerProvider.notifier)
                  .changeLocale(localeEnglish),
              leading: SvgPicture.asset(assetEnglish),
              onChanged:
                  ref.read(localeControllerProvider.notifier).changeLocale,
              providerValue: locale,
              radioValue: localeEnglish,
              text: context.l.english,
            ),
            RadioItem<Locale>(
              onTap: () => ref
                  .read(localeControllerProvider.notifier)
                  .changeLocale(localeTurkish),
              leading: SvgPicture.asset(assetTurkish),
              onChanged:
                  ref.read(localeControllerProvider.notifier).changeLocale,
              providerValue: locale,
              radioValue: localeTurkish,
              text: context.l.turkish,
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
