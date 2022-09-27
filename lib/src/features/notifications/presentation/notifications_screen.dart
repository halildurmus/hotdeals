import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../common_widgets/error_indicator.dart';
import '../../../helpers/context_extensions.dart';
import '../domain/push_notification.dart';
import 'notifications_controller.dart';
import 'widgets/notification_item.dart';
import 'widgets/notifications_screen_appbar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notificationsControllerProvider);

    return WillPopScope(
      onWillPop: ref.read(notificationsControllerProvider.notifier).onWillPop,
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: NotificationsScreenAppBar(),
        ),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(controller.pagingController.refresh),
          child: PagedListView.separated(
            pagingController: controller.pagingController,
            builderDelegate: PagedChildBuilderDelegate<PushNotification>(
              animateTransitions: true,
              itemBuilder: (context, notification, index) =>
                  NotificationItem(notification: notification),
              firstPageErrorIndicatorBuilder: (context) => NoConnectionError(
                onPressed: controller.pagingController.refresh,
              ),
              newPageErrorIndicatorBuilder: (context) =>
                  SomethingWentWrongError(
                onPressed: controller.pagingController.refresh,
              ),
              noItemsFoundIndicatorBuilder: (context) => ErrorIndicator(
                icon: Icons.notifications_none_outlined,
                title: context.l.noNotifications,
              ),
            ),
            separatorBuilder: (context, index) => const Divider(
              height: 0,
              indent: 16,
              endIndent: 16,
            ),
          ),
        ),
      ),
    );
  }
}
