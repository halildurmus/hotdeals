import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/push_notification.dart';
import '../services/push_notification_service.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/error_indicator.dart';
import '../widgets/notification_item.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with NetworkLoggy {
  static const kPageSize = 10;
  late PagingController<int, PushNotification> _pagingController;
  late PushNotificationService _pushNotificationService;

  @override
  void initState() {
    _pagingController =
        PagingController<int, PushNotification>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    _pushNotificationService = GetIt.I.get<PushNotificationService>();
    _pushNotificationService.addListener(() => _pagingController.refresh());
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _pushNotificationService.getAll(
          offset: pageKey, limit: kPageSize);
      final isLastPage = newItems.length < kPageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      loggy.error(error);
      _pagingController.error = error;
    }
  }

  Widget buildNoNotificationsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.notifications_none_outlined,
      title: AppLocalizations.of(context)!.noNotifications,
    );
  }

  Widget _buildPagedListView() {
    return PagedListView.separated(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<PushNotification>(
        animateTransitions: true,
        itemBuilder: (context, notification, index) =>
            NotificationItem(notification: notification),
        firstPageErrorIndicatorBuilder: (context) =>
            ErrorIndicatorUtil.buildFirstPageError(
          context,
          onTryAgain: () => _pagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) =>
            ErrorIndicatorUtil.buildNewPageError(
          context,
          onTryAgain: () => _pagingController.refresh(),
        ),
        noItemsFoundIndicatorBuilder: (context) =>
            buildNoNotificationsFound(context),
      ),
      separatorBuilder: (context, index) => const Divider(
        height: 0,
        indent: 16,
        endIndent: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: _buildPagedListView(),
      ),
    );
  }
}
