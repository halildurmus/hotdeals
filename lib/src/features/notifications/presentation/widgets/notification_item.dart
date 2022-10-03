import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/hotdeals_repository.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../../helpers/date_time_helper.dart';
import '../../../auth/domain/my_user.dart';
import '../../../settings/presentation/locale_controller.dart';
import '../../data/push_notification_service.dart';
import '../../domain/push_notification.dart';
import '../notifications_controller.dart';

class NotificationItem extends ConsumerWidget with NetworkLoggy {
  const NotificationItem({required this.notification, super.key});

  final PushNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notificationsControllerProvider);
    final isItemSelected = controller.items[notification.id] ?? false;
    final user = ref.watch(userByIdFutureProvider(notification.actor));

    return user.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 25),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        loggy.error(error, error);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(context.l.anErrorOccurred, textAlign: TextAlign.center),
        );
      },
      data: (user) {
        return Card(
          color: isItemSelected
              ? context.t.primaryColor.withOpacity(.2)
              : !notification.isRead
                  ? context.t.primaryColor.withOpacity(.1)
                  : null,
          elevation: 0,
          margin: EdgeInsets.zero,
          child: ListTile(
            onLongPress: () {
              ref
                  .read(notificationsControllerProvider.notifier)
                  .selectItem(notification.id!);
              ref
                  .read(notificationsControllerProvider.notifier)
                  .enableSelectionMode();
            },
            onTap: () async {
              if (controller.isSelectionModeActive) {
                ref
                    .read(notificationsControllerProvider.notifier)
                    .selectItem(notification.id!);
              } else if (!controller.isSelectionModeActive &&
                  !notification.isRead) {
                ref
                    .read(notificationsControllerProvider.notifier)
                    .markSelectedNotificationAsRead(notification.id!);
                await ref
                    .read(pushNotificationServiceProvider)
                    .markAsRead([notification.id!]);
              }
            },
            isThreeLine: notification.verb == NotificationVerb.comment,
            leading: _Leading(
              isItemSelected: isItemSelected,
              isSelectionModeActive: controller.isSelectionModeActive,
              user: user,
            ),
            title: _Title(user: user, notification: notification),
            subtitle: (notification.verb == NotificationVerb.comment)
                ? _CommentNotificationSubtitle(notification: notification)
                : _MessageNotificationSubtitle(notification: notification),
            trailing: notification.isRead ? null : const _Trailing(),
          ),
        );
      },
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({
    required this.isItemSelected,
    required this.isSelectionModeActive,
    required this.user,
  });

  final bool isItemSelected;
  final bool isSelectionModeActive;
  final MyUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelectionModeActive)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isItemSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: context.t.primaryColor,
              ),
            ],
          ),
        if (isSelectionModeActive) const SizedBox(width: 16),
        CachedNetworkImage(
          imageUrl: user.avatar!,
          imageBuilder: (ctx, imageProvider) =>
              CircleAvatar(backgroundImage: imageProvider),
          placeholder: (context, url) => const CircleAvatar(),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.notification, required this.user});

  final PushNotification notification;
  final MyUser user;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: user.nickname,
        style:
            context.textTheme.bodyText2!.copyWith(fontWeight: FontWeight.w500),
        children: [
          if (notification.verb == NotificationVerb.comment)
            TextSpan(
              text: context.l.commentedOnYourPost,
              style: context.textTheme.bodyText2,
            ),
        ],
      ),
    );
  }
}

class _CommentNotificationSubtitle extends StatelessWidget {
  const _CommentNotificationSubtitle({required this.notification});

  final PushNotification notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${notification.message}"',
          style: context.textTheme.bodyText2!
              .copyWith(color: context.colorScheme.secondary),
        ),
        const SizedBox(height: 5),
        Consumer(
          builder: (context, ref, child) {
            final locale = ref.watch(localeControllerProvider);
            return Text(
              formatDateTime(
                notification.createdAt!,
                locale: locale,
                useShortMessages: false,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MessageNotificationSubtitle extends StatelessWidget {
  const _MessageNotificationSubtitle({required this.notification});

  final PushNotification notification;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final locale = ref.watch(localeControllerProvider);
        return Text(
          formatDateTime(
            notification.createdAt!,
            locale: locale,
            useShortMessages: false,
          ),
        );
      },
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: context.isDarkMode
              ? context.t.primaryColor
              : context.t.primaryColorLight,
          radius: 6,
        ),
      ],
    );
  }
}
