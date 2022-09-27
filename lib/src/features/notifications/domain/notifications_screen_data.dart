import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'push_notification.dart';

@immutable
class NotificationsScreenData {
  const NotificationsScreenData({
    required this.hasSelectedItem,
    required this.hasUnreadSelectedItem,
    required this.isSelectionModeActive,
    required this.items,
    required this.pagingController,
    required this.selectedItemCount,
  });

  final bool hasSelectedItem;
  final bool hasUnreadSelectedItem;
  final bool isSelectionModeActive;
  final Map<int, bool> items;
  final PagingController<int, PushNotification> pagingController;
  final int selectedItemCount;

  NotificationsScreenData copyWith({
    bool? hasSelectedItem,
    bool? hasUnreadSelectedItem,
    bool? isSelectionModeActive,
    Map<int, bool>? items,
    PagingController<int, PushNotification>? pagingController,
    int? selectedItemCount,
  }) =>
      NotificationsScreenData(
        hasSelectedItem: hasSelectedItem ?? this.hasSelectedItem,
        hasUnreadSelectedItem:
            hasUnreadSelectedItem ?? this.hasUnreadSelectedItem,
        isSelectionModeActive:
            isSelectionModeActive ?? this.isSelectionModeActive,
        items: items ?? this.items,
        pagingController: pagingController ?? this.pagingController,
        selectedItemCount: selectedItemCount ?? this.selectedItemCount,
      );
}
