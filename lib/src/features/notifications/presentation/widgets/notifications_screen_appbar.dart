import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../helpers/context_extensions.dart';
import '../notifications_controller.dart';

enum _NotificationPopup { selectAll, deselectAll }

class NotificationsScreenAppBar extends ConsumerWidget {
  const NotificationsScreenAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notificationsControllerProvider);
    if (!controller.isSelectionModeActive) {
      return AppBar(
        title: Text(context.l.notifications),
      );
    }

    return AppBar(
      backgroundColor: context.isDarkMode
          ? context.t.primaryColor
          : context.t.primaryColorDark,
      leading: IconButton(
        onPressed: ref
            .read(notificationsControllerProvider.notifier)
            .disableSelectionMode,
        icon: const Icon(Icons.close),
      ),
      title: Text('${controller.selectedItemCount} ${context.l.selected}'),
      actions: [
        if (controller.hasSelectedItem)
          IconButton(
            onPressed: controller.hasUnreadSelectedItem
                ? ref
                    .read(notificationsControllerProvider.notifier)
                    .markSelectedNotificationsAsRead
                : ref
                    .read(notificationsControllerProvider.notifier)
                    .markSelectedNotificationsAsUnread,
            icon: Icon(
              controller.hasUnreadSelectedItem
                  ? FontAwesomeIcons.circle
                  : FontAwesomeIcons.solidCircle,
            ),
            iconSize: 14,
            tooltip: controller.hasUnreadSelectedItem
                ? context.l.markAsRead
                : context.l.markAsUnread,
          ),
        PopupMenuButton<_NotificationPopup>(
          icon: const Icon(Icons.more_vert),
          onSelected: (result) {
            switch (result) {
              case _NotificationPopup.selectAll:
                ref
                    .read(notificationsControllerProvider.notifier)
                    .onSelectAll(true);
                break;
              case _NotificationPopup.deselectAll:
                ref
                    .read(notificationsControllerProvider.notifier)
                    .onSelectAll(false);
                break;
            }
          },
          itemBuilder: (context) {
            final hasUnselectedItem = controller.items.containsValue(false);
            return [
              if (hasUnselectedItem)
                PopupMenuItem<_NotificationPopup>(
                  value: _NotificationPopup.selectAll,
                  child: Text(context.l.selectAll),
                ),
              PopupMenuItem<_NotificationPopup>(
                value: _NotificationPopup.deselectAll,
                child: Text(context.l.deselectAll),
              ),
            ];
          },
        ),
      ],
    );
  }
}
