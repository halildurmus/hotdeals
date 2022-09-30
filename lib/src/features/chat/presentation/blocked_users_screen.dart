import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/custom_alert_dialog.dart';
import '../../../common_widgets/custom_snack_bar.dart';
import '../../../common_widgets/error_indicator.dart';
import '../../../common_widgets/user_profile_dialog.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../helpers/context_extensions.dart';
import '../../auth/domain/my_user.dart';
import '../../auth/presentation/user_controller.dart';
import 'blocked_users_screen_controller.dart';

final _blockedUsersFutureProvider =
    FutureProvider.autoDispose<List<MyUser>?>((ref) async {
  final hotdealsRepository = ref.watch(hotdealsRepositoryProvider);
  return await hotdealsRepository.getBlockedUsers();
}, name: 'BlockedUsersFutureProvider');

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsers = ref.watch(_blockedUsersFutureProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.blockedUsers),
      ),
      body: blockedUsers.when(
        data: (users) {
          if (users == null || users.isEmpty) {
            return ErrorIndicator(
              icon: Icons.person_outline,
              title: context.l.noBlockedUsers,
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _BlockedUserCard(user: user);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => NoConnectionError(
          onPressed: () => ref.refresh(_blockedUsersFutureProvider),
        ),
      ),
    );
  }
}

class _BlockedUserCard extends ConsumerStatefulWidget {
  const _BlockedUserCard({required this.user});

  final MyUser user;

  @override
  ConsumerState<_BlockedUserCard> createState() => _BlockedUserCardState();
}

class _BlockedUserCardState extends ConsumerState<_BlockedUserCard> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(blockedUsersScreenControllerProvider);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) =>
              UserProfileDialog(userId: widget.user.id!, showButtons: false),
        ),
        leading: CachedNetworkImage(
          imageUrl: widget.user.avatar!,
          imageBuilder: (ctx, imageProvider) =>
              CircleAvatar(backgroundImage: imageProvider),
          placeholder: (context, url) => const CircleAvatar(),
        ),
        title: Text(
          widget.user.nickname!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: OutlinedButton(
          onPressed: () => CustomAlertDialog(
            title: context.l.unblockUser,
            content: context.l.unblockConfirm,
            defaultAction: () async => await controller.unblockUser(
              userId: widget.user.id!,
              onSuccess: () async {
                await ref.read(userProvider.notifier).refreshUser();
                ref.refresh(_blockedUsersFutureProvider);
                if (!mounted) return;
                CustomSnackBar.success(
                  text: context.l.successfullyUnblocked,
                ).showSnackBar(context);
              },
              onFailure: () {
                CustomSnackBar.error(
                  text: context.l.anErrorOccurredWhileUnblocking,
                ).showSnackBar(context);
              },
            ),
            cancelActionText: context.l.cancel,
          ).show(context),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(color: context.t.errorColor),
          ),
          child: Text(
            context.l.unblock,
            style: context.textTheme.subtitle2!
                .copyWith(color: context.t.errorColor),
          ),
        ),
      ),
    );
  }
}
