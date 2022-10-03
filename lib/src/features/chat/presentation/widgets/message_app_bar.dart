import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common_widgets/circle_avatar_shimmer.dart';
import '../../../../common_widgets/custom_alert_dialog.dart';
import '../../../../common_widgets/custom_snack_bar.dart';
import '../../../../common_widgets/report_user_dialog.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../auth/domain/my_user.dart';
import '../../../auth/presentation/user_controller.dart';

enum _MessagePopup { blockUser, unblockUser, reportUser }

class MessageAppBar extends ConsumerStatefulWidget {
  const MessageAppBar({required this.user2, super.key});

  final MyUser user2;

  @override
  ConsumerState<MessageAppBar> createState() => _MessageAppBarState();
}

class _MessageAppBarState extends ConsumerState<MessageAppBar> {
  Future<void> _confirmBlockUser(BuildContext context) async {
    await CustomAlertDialog(
      title: context.l.blockUser,
      content: context.l.blockConfirm,
      defaultAction: () async {
        final result = await ref
            .read(hotdealsRepositoryProvider)
            .blockUser(userId: widget.user2.id!);
        if (result) {
          await ref.read(userProvider.notifier).refreshUser();
          if (!mounted) return;
          CustomSnackBar.success(text: context.l.successfullyBlocked)
              .showSnackBar(context);
        } else {
          if (!mounted) return;
          CustomSnackBar.error(text: context.l.anErrorOccurredWhileBlocking)
              .showSnackBar(context);
        }
      },
      cancelActionText: context.l.cancel,
    ).show(context);
  }

  Future<void> _confirmUnblockUser(BuildContext context) async {
    await CustomAlertDialog(
      title: context.l.unblockUser,
      content: context.l.unblockConfirm,
      defaultAction: () async {
        final result = await ref
            .read(hotdealsRepositoryProvider)
            .unblockUser(userId: widget.user2.id!);
        if (result) {
          await ref.read(userProvider.notifier).refreshUser();
          if (!mounted) return;
          CustomSnackBar.success(text: context.l.successfullyUnblocked)
              .showSnackBar(context);
        } else {
          if (!mounted) return;
          CustomSnackBar.error(text: context.l.anErrorOccurredWhileUnblocking)
              .showSnackBar(context);
        }
      },
      cancelActionText: context.l.cancel,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isUserBlocked = user.blockedUsers!.contains(widget.user2.id!);

    return AppBar(
      actions: [
        PopupMenuButton<_MessagePopup>(
          icon: const Icon(Icons.more_vert),
          onSelected: (result) async {
            switch (result) {
              case _MessagePopup.blockUser:
                await _confirmBlockUser(context);
                break;
              case _MessagePopup.unblockUser:
                await _confirmUnblockUser(context);
                break;
              case _MessagePopup.reportUser:
                await showDialog<void>(
                  context: context,
                  builder: (context) =>
                      ReportUserDialog(userId: widget.user2.id!),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<_MessagePopup>(
              value: isUserBlocked
                  ? _MessagePopup.unblockUser
                  : _MessagePopup.blockUser,
              child: isUserBlocked
                  ? Text(context.l.unblockUser)
                  : Text(context.l.blockUser),
            ),
            PopupMenuItem<_MessagePopup>(
              value: _MessagePopup.reportUser,
              child: Text(context.l.reportUser),
            ),
          ],
        ),
      ],
      title: ListTile(
        horizontalTitleGap: 8,
        leading: CachedNetworkImage(
          imageUrl: widget.user2.avatar!,
          imageBuilder: (_, imageProvider) =>
              CircleAvatar(backgroundImage: imageProvider, radius: 16),
          errorWidget: (_, __, ___) => const CircleAvatarShimmer(radius: 16),
          placeholder: (_, __) => const CircleAvatarShimmer(radius: 16),
        ),
        title: Text(
          widget.user2.nickname!,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyText2!.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
