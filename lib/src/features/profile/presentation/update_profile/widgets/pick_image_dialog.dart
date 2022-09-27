import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart';

import '../../../../../common_widgets/custom_snack_bar.dart';
import '../../../../../helpers/context_extensions.dart';
import '../update_avatar_controller.dart';

class PickImageDialog extends ConsumerWidget with UiLoggy {
  const PickImageDialog({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(updateAvatarControllerProvider, (prev, next) {
      if (!next.isRefreshing) {
        Navigator.of(context).pop();
        if (next.hasError) {
          const CustomSnackBar.error().showSnackBar(context);
        } else if (next.value ?? false) {
          CustomSnackBar.success(text: context.l.successfullyUpdatedYourAvatar)
              .showSnackBar(context);
        }
      }
    });

    return Wrap(
      children: [
        ListTile(
          horizontalTitleGap: 0,
          leading: GestureDetector(
            onTap: Navigator.of(context).pop,
            child: const Icon(
              FontAwesomeIcons.xmark,
              color: Color.fromRGBO(148, 148, 148, 1),
              size: 20,
            ),
          ),
          title: Text(
            context.l.selectSource,
            style: context.textTheme.subtitle1!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.photo_camera),
          title: Text(context.l.camera),
          onTap: () => ref
              .read(updateAvatarControllerProvider.notifier)
              .updateAvatar(userId, ImageSource.camera),
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.photo_library),
          title: Text(context.l.gallery),
          onTap: () => ref
              .read(updateAvatarControllerProvider.notifier)
              .updateAvatar(userId, ImageSource.gallery),
        ),
      ],
    );
  }
}
