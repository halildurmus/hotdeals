import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:loggy/loggy.dart' show UiLoggy;

import '../../../../common_widgets/custom_alert_dialog.dart';
import '../../../../common_widgets/custom_snack_bar.dart';
import '../../../../common_widgets/settings_list_item.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../auth/presentation/user_controller.dart';
import 'signout_controller.dart';
import 'widgets/pick_image_dialog.dart';
import 'widgets/update_nickname_dialog.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends ConsumerState<UpdateProfileScreen>
    with UiLoggy {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nicknameTextEditingController;
  late FocusNode nicknameFocusNode;

  @override
  void initState() {
    final user = ref.read(userProvider)!;
    nicknameTextEditingController = TextEditingController(text: user.nickname);
    nicknameFocusNode = FocusNode()..requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    nicknameTextEditingController.dispose();
    nicknameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const SizedBox();
    ref.listen<AsyncValue<bool>>(signOutControllerProvider, (prev, next) {
      if (!next.isRefreshing && next.hasError) {
        Navigator.of(context).pop();
        const CustomSnackBar.error().showSnackBar(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.updateProfile),
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsListItem(
            onTap: () => showModalBottomSheet<void>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              builder: (_) => PickImageDialog(userId: user.id!),
            ),
            leading: CachedNetworkImage(
              imageUrl: user.avatar!,
              imageBuilder: (_, imageProvider) =>
                  CircleAvatar(backgroundImage: imageProvider),
              placeholder: (_, __) => const CircleAvatar(),
            ),
            title: context.l.avatar,
          ),
          SettingsListItem(
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => UpdateNicknameDialog(
                controller: nicknameTextEditingController,
                focusNode: nicknameFocusNode,
                formKey: formKey,
              ),
            ),
            leading: const Icon(Icons.edit),
            title: context.l.nickname,
            subtitle: user.nickname,
          ),
          SettingsListItem(
            onTap: () => CustomAlertDialog(
              title: context.l.logoutConfirm,
              cancelActionText: context.l.cancel,
              defaultAction:
                  ref.read(signOutControllerProvider.notifier).signOut,
              defaultActionText: context.l.logout,
            ).show(context),
            hasNavigation: false,
            leading: const Icon(Icons.logout),
            title: context.l.logout,
          ),
        ],
      ),
    );
  }
}
