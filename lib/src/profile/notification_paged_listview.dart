import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/push_notification.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/notification_item.dart';

class NotificationPagedListView extends StatefulWidget {
  const NotificationPagedListView({
    Key? key,
    required this.notificationFuture,
    required this.noNotificationsFound,
    this.pageSize = 20,
    this.pagingController,
    this.useRefreshIndicator = true,
  }) : super(key: key);

  final Future<List<PushNotification>?> Function(int page, int size)
      notificationFuture;
  final Widget noNotificationsFound;
  final int pageSize;
  final PagingController<int, PushNotification>? pagingController;
  final bool useRefreshIndicator;

  @override
  _NotificationPagedListViewState createState() =>
      _NotificationPagedListViewState();
}

class _NotificationPagedListViewState extends State<NotificationPagedListView>
    with NetworkLoggy {
  late PagingController<int, PushNotification> _pagingController;

  @override
  void initState() {
    _pagingController = widget.pagingController ??
        PagingController<int, PushNotification>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    super.initState();
  }

  @override
  void dispose() {
    if (widget.pagingController == null) {
      _pagingController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await widget.notificationFuture(pageKey, widget.pageSize);
      final isLastPage = newItems!.length < widget.pageSize;
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

  @override
  Widget build(BuildContext context) {
    Widget buildPagedListView() {
      return PagedListView.separated(
        pagingController: _pagingController,
        padding: const EdgeInsets.symmetric(vertical: 16),
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
              widget.noNotificationsFound,
        ),
        separatorBuilder: (context, index) => const Divider(
          height: 0,
          indent: 16,
          endIndent: 16,
        ),
      );
    }

    if (!widget.useRefreshIndicator) {
      return buildPagedListView();
    }

    return RefreshIndicator(
      onRefresh: () => Future.sync(() => _pagingController.refresh()),
      child: buildPagedListView(),
    );
  }
}
