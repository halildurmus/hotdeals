import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/push_notification_service.dart';
import '../utils/error_indicator_util.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/error_indicator.dart';
import 'notification_item.dart';
import 'push_notification.dart';

enum _NotificationPopup { selectAll, deselectAll }

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with NetworkLoggy {
  static const _pageSize = 12;
  late MyUser? _user;
  final _pagingController =
      PagingController<int, PushNotification>(firstPageKey: 0);
  late final PushNotificationService _pushNotificationService;
  late final StreamSubscription<PushNotification> _notification;
  bool _isSelectionMode = false;
  final Map<int, bool> _items = {};

  @override
  void initState() {
    _user = context.read<UserController>().user;
    _pagingController.addPageRequestListener(_fetchPage);
    _pushNotificationService = GetIt.I.get<PushNotificationService>();
    _notification = _pushNotificationService.notification.listen((event) {
      if (_pagingController.itemList != null &&
          !_pagingController.itemList!.contains(event)) {
        _pagingController.itemList!.insert(0, event);
        if (mounted) {
          setState(() {});
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _notification.cancel();
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
    setState(() => _items.updateAll((key, value) => shouldSelectAll));
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _pushNotificationService.getAll(
          offset: pageKey, limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } on Exception catch (error) {
      loggy.error(error);
      _pagingController.error = error;
    }
  }

  Widget buildNoNotificationsFound(BuildContext context) => ErrorIndicator(
        icon: Icons.notifications_none_outlined,
        title: l(context).noNotifications,
      );

  List<PushNotification> _getSelectedNotifications() {
    final selectedItems = Map.from(_items)..removeWhere((k, v) => v == false);

    return _pagingController.itemList!
        .where((e) => selectedItems.keys.contains(e.id))
        .toList(growable: false);
  }

  Future<void> _markSelectedAsRead() async {
    var updatedNotificationCount = 0;
    final notifications = _getSelectedNotifications();
    final ids = <int>[];
    setState(() {
      for (final notification in notifications) {
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
    final snackBar = CustomSnackBar(
      icon: const Icon(FontAwesomeIcons.circleCheck, size: 20),
      text: l(context).markedNotificationAsRead(updatedNotificationCount),
    ).buildSnackBar(context);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _markSelectedAsUnread() async {
    var updatedNotificationCount = 0;
    final notifications = _getSelectedNotifications();
    final ids = <int>[];
    setState(() {
      for (final notification in notifications) {
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
    final snackBar = CustomSnackBar(
      icon: const Icon(FontAwesomeIcons.circleCheck, size: 20),
      text: l(context).markedNotificationAsUnread(updatedNotificationCount),
    ).buildSnackBar(context);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _onTap(bool isSelected, PushNotification notification) async {
    if (_isSelectionMode) {
      setState(() => _items[notification.id!] = !isSelected);
    } else if (!_isSelectionMode && !notification.isRead) {
      setState(() => notification.isRead = true);
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

  Widget _buildPagedListView() => PagedListView.separated(
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
            onTryAgain: _pagingController.refresh,
          ),
          newPageErrorIndicatorBuilder: (context) =>
              ErrorIndicatorUtil.buildNewPageError(
            context,
            onTryAgain: _pagingController.refresh,
          ),
          noItemsFoundIndicatorBuilder: buildNoNotificationsFound,
        ),
        separatorBuilder: (context, index) => const Divider(
          height: 0,
          indent: 16,
          endIndent: 16,
        ),
      );

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    var isSelectedItemAvailable = false;
    var isSelectedUnreadItemAvailable = false;
    var selectedItemCount = 0;
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
            ? '$selectedItemCount ${l(context).selected}'
            : l(context).notifications,
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
                      ? l(context).markAsRead
                      : l(context).markAsUnread,
                ),
              PopupMenuButton<_NotificationPopup>(
                icon: const Icon(Icons.more_vert),
                onSelected: (result) {
                  switch (result) {
                    case _NotificationPopup.selectAll:
                      _onSelectAll(true);
                      break;
                    case _NotificationPopup.deselectAll:
                      _onSelectAll(false);
                      break;
                  }
                },
                itemBuilder: (context) {
                  final isUnselectedItemAvailable = _items.containsValue(false);

                  return [
                    if (isUnselectedItemAvailable)
                      PopupMenuItem<_NotificationPopup>(
                        value: _NotificationPopup.selectAll,
                        child: Text(l(context).selectAll),
                      ),
                    PopupMenuItem<_NotificationPopup>(
                      value: _NotificationPopup.deselectAll,
                      child: Text(l(context).deselectAll),
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

  Widget _buildSignIn() => ErrorIndicator(
        icon: Icons.notifications_none_outlined,
        title: l(context).youNeedToSignIn,
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () => Future.sync(_pagingController.refresh),
            child: _user == null ? _buildSignIn() : _buildPagedListView(),
          ),
        ),
      );
}
