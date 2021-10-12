import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/push_notification.dart';
import '../services/push_notification_service.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/error_indicator.dart';
import 'notification_item.dart';

enum _NotificationPopup { selectAll, deselectAll }

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with NetworkLoggy {
  static const kPageSize = 10;
  final _pagingController =
      PagingController<int, PushNotification>(firstPageKey: 0);
  late final PushNotificationService _pushNotificationService;
  late final StreamSubscription<PushNotification> _notifications;
  bool _isSelectionMode = false;
  final Map<int, bool> _items = {};

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    _pushNotificationService = GetIt.I.get<PushNotificationService>();
    _notifications = _pushNotificationService.notifications.listen((event) {
      if (_pagingController.itemList != null &&
          !_pagingController.itemList!.contains(event)) {
        setState(() {
          _pagingController.itemList!.insert(0, event);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _notifications.cancel();
    super.dispose();
  }

  void _disableSelectionMode() {
    setState(() {
      _items.updateAll((key, value) => false);
      _isSelectionMode = false;
    });
  }

  void _onSelectAll(bool shouldSelectAll) {
    // If shouldSelectAll is true, it will select all items. Otherwise it will
    // de-select them.
    setState(() {
      _items.updateAll((key, value) => shouldSelectAll);
    });
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

  List<PushNotification> _getSelectedNotifications() {
    final selectedItems = Map.from(_items)..removeWhere((k, v) => v == false);

    return _pagingController.itemList!
        .where((e) => selectedItems.keys.contains(e.id))
        .toList(growable: false);
  }

  Future<void> _markSelectedAsRead() async {
    int updatedNotificationCount = 0;
    final notifications = _getSelectedNotifications();
    final ids = <int>[];
    setState(() {
      for (var notification in notifications) {
        if (!notification.isRead) {
          ids.add(notification.id!);
          updatedNotificationCount++;
          notification.isRead = true;
        }
        _items[notification.id!] = false;
      }
      _isSelectionMode = false;
    });
    await GetIt.I.get<PushNotificationService>().markAsRead(ids);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked $updatedNotificationCount notification as read'),
      ),
    );
  }

  Future<void> _markSelectedAsUnread() async {
    int updatedNotificationCount = 0;
    final notifications = _getSelectedNotifications();
    final ids = <int>[];
    setState(() {
      for (var notification in notifications) {
        if (notification.isRead) {
          ids.add(notification.id!);
          updatedNotificationCount++;
          notification.isRead = false;
        }
        _items[notification.id!] = false;
      }
      _isSelectionMode = false;
    });
    await GetIt.I.get<PushNotificationService>().markAsUnread(ids);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Marked $updatedNotificationCount notification as unread'),
      ),
    );
  }

  Future<void> _onTap(bool isSelected, PushNotification notification) async {
    if (_isSelectionMode) {
      setState(() {
        _items[notification.id!] = !isSelected;
      });
    } else if (!_isSelectionMode && !notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
      await GetIt.I
          .get<PushNotificationService>()
          .markAsRead([notification.id!]);
    }
  }

  void _onLongPress(bool isSelected, PushNotification notification) {
    setState(() {
      _items[notification.id!] = !isSelected;
      _isSelectionMode = true;
    });
  }

  Widget _buildPagedListView() {
    return PagedListView.separated(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<PushNotification>(
        animateTransitions: true,
        itemBuilder: (context, notification, index) {
          final notificationId = notification.id!;
          _items[notificationId] ??= false;
          final isSelected = _items[notificationId]!;

          return NotificationItem(
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            notification: notification,
            onLongPress: () => _onLongPress(isSelected, notification),
            onTap: () => _onTap(isSelected, notification),
          );
        },
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

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    bool isSelectedItemAvailable = false;
    bool isSelectedUnreadItemAvailable = false;
    int selectedItemCount = 0;
    if (_isSelectionMode) {
      isSelectedItemAvailable = _items.containsValue(true);
      selectedItemCount = _items.values.where((e) => e == true).length;
      final notifications = _getSelectedNotifications();
      isSelectedUnreadItemAvailable =
          notifications.where((e) => !e.isRead).isNotEmpty;
    }

    return AppBar(
      backgroundColor: _isSelectionMode
          ? isDarkMode
              ? theme.primaryColor
              : theme.primaryColorDark
          : null,
      leading: _isSelectionMode
          ? IconButton(
              onPressed: _disableSelectionMode,
              icon: const Icon(Icons.close),
            )
          : null,
      title: Text(
        _isSelectionMode
            ? '$selectedItemCount ${AppLocalizations.of(context)!.selected}'
            : AppLocalizations.of(context)!.notifications,
      ),
      actions: _isSelectionMode
          ? [
              if (isSelectedItemAvailable)
                IconButton(
                  onPressed: isSelectedUnreadItemAvailable
                      ? _markSelectedAsRead
                      : _markSelectedAsUnread,
                  icon: Icon(isSelectedUnreadItemAvailable
                      ? FontAwesomeIcons.circle
                      : FontAwesomeIcons.solidCircle),
                  iconSize: 14,
                  tooltip: isSelectedUnreadItemAvailable
                      ? AppLocalizations.of(context)!.markAsRead
                      : AppLocalizations.of(context)!.markAsUnread,
                ),
              PopupMenuButton<_NotificationPopup>(
                icon: const Icon(Icons.more_vert),
                onSelected: (_NotificationPopup result) {
                  if (result == _NotificationPopup.selectAll) {
                    _onSelectAll(true);
                  } else if (result == _NotificationPopup.deselectAll) {
                    _onSelectAll(false);
                  }
                },
                itemBuilder: (context) {
                  final isUnselectedItemAvailable = _items.containsValue(false);

                  return [
                    if (isUnselectedItemAvailable)
                      PopupMenuItem<_NotificationPopup>(
                        value: _NotificationPopup.selectAll,
                        child: Text(AppLocalizations.of(context)!.selectAll),
                      ),
                    PopupMenuItem<_NotificationPopup>(
                      value: _NotificationPopup.deselectAll,
                      child: Text(AppLocalizations.of(context)!.deselectAll),
                    ),
                  ];
                },
              ),
            ]
          : null,
    );
  }

  Future<bool> _onWillPop() {
    if (_isSelectionMode) {
      _disableSelectionMode();

      return Future<bool>.value(false);
    }

    return Future<bool>.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: _buildPagedListView(),
        ),
      ),
    );
  }
}
