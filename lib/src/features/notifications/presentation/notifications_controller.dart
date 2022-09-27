import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart';

import '../data/push_notification_service.dart';
import '../domain/notifications_screen_data.dart';
import '../domain/push_notification.dart';

final notificationsControllerProvider = StateNotifierProvider.autoDispose<
        NotificationsController, NotificationsScreenData>(
    (ref) => NotificationsController(
          ref.read,
          pagingController: PagingController(firstPageKey: 0),
        ),
    name: 'NotificationsControllerProvider');

class NotificationsController extends StateNotifier<NotificationsScreenData>
    with NetworkLoggy {
  NotificationsController(Reader read, {required this.pagingController})
      : _pushNotificationService = read(pushNotificationServiceProvider),
        super(
          NotificationsScreenData(
            hasSelectedItem: false,
            hasUnreadSelectedItem: false,
            isSelectionModeActive: false,
            items: const {},
            pagingController: pagingController,
            selectedItemCount: 0,
          ),
        ) {
    init();
  }

  static const _pageSize = 12;
  final PagingController<int, PushNotification> pagingController;
  final PushNotificationService _pushNotificationService;
  late final StreamSubscription<PushNotification> _notificationStream;

  void init() {
    pagingController.addPageRequestListener(_fetchPage);
    _notificationStream =
        _pushNotificationService.notification.listen((notification) {
      if (pagingController.itemList != null &&
          !pagingController.itemList!.contains(notification)) {
        pagingController.itemList!.insert(0, notification);
        final items = Map.of(state.items);
        items[notification.id!] ??= false;
        state = state.copyWith(items: items);
      }
    });
  }

  @override
  void dispose() {
    pagingController.dispose();
    _notificationStream.cancel();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _pushNotificationService.getAll(
          offset: pageKey, limit: _pageSize);

      final ids = newItems.map((e) => e.id!).toList();
      final items = Map.of(state.items);
      for (final id in ids) {
        items[id] ??= false;
      }

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }

      state = state.copyWith(items: items);
    } on Exception catch (error) {
      loggy.error(error);
      pagingController.error = error;
    }
  }

  Future<bool> onWillPop() {
    if (!state.isSelectionModeActive) return Future<bool>.value(true);
    disableSelectionMode();
    return Future<bool>.value(false);
  }

  void markSelectedNotificationAsRead(int id) {
    final notification =
        pagingController.itemList!.firstWhere((e) => e.id == id);
    // ignore: cascade_invocations
    notification.isRead = true;
    state = state.copyWith(pagingController: pagingController);
  }

  Future<int> markSelectedNotificationsAsRead() async {
    var updatedNotificationCount = 0;
    final notifications = _getSelectedNotifications();
    final ids = <int>[];
    final items = Map.of(state.items);

    for (final notification in notifications) {
      if (!notification.isRead) {
        ids.add(notification.id!);
        updatedNotificationCount++;
        notification.isRead = true;
      }
      items[notification.id!] = false;
    }

    state = state.copyWith(isSelectionModeActive: false, items: items);
    await _pushNotificationService.markAsRead(ids);

    return updatedNotificationCount;
  }

  Future<int> markSelectedNotificationsAsUnread() async {
    var updatedNotificationCount = 0;
    final notifications = _getSelectedNotifications();
    final ids = <int>[];
    final items = Map.of(state.items);

    for (final notification in notifications) {
      if (notification.isRead) {
        ids.add(notification.id!);
        updatedNotificationCount++;
        notification.isRead = false;
      }
      items[notification.id!] = false;
    }

    state = state.copyWith(isSelectionModeActive: false, items: items);
    await _pushNotificationService.markAsUnread(ids);

    return updatedNotificationCount;
  }

  List<PushNotification> _getSelectedNotifications() {
    final selectedItems = Map.of(state.items)
      ..removeWhere((k, v) => v == false);
    return pagingController.itemList!
        .where((e) => selectedItems.keys.contains(e.id))
        .toList(growable: false);
  }

  void enableSelectionMode() {
    final selectedNotifications = _getSelectedNotifications();
    final hasUnreadSelectedItem =
        selectedNotifications.where((e) => !e.isRead).isNotEmpty;

    state = state.copyWith(
      hasSelectedItem: state.items.containsValue(true),
      hasUnreadSelectedItem: hasUnreadSelectedItem,
      isSelectionModeActive: true,
      selectedItemCount: state.items.values.where((e) => e == true).length,
    );
  }

  void disableSelectionMode() {
    final items = Map.of(state.items)..updateAll((key, value) => false);
    state = state.copyWith(isSelectionModeActive: false, items: items);
  }

  /// If [shouldSelectAll] is `true`, it will select all items. Otherwise it
  /// will de-select them.
  void onSelectAll(bool shouldSelectAll) {
    final items = Map.of(state.items)
      ..updateAll((key, value) => shouldSelectAll);
    state = state.copyWith(
      items: items,
      selectedItemCount: items.values.where((e) => e == true).length,
    );
  }

  void selectItem(int id) {
    final isSelected = state.items[id] ?? false;
    final items = Map.of(state.items);
    items[id] = !isSelected;
    state = state.copyWith(
      items: items,
      selectedItemCount: items.values.where((e) => e == true).length,
    );
  }
}
