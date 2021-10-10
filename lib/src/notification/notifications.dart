import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/push_notification.dart';
import '../services/push_notification_service.dart';
import '../widgets/error_indicator.dart';
import 'notification_paged_listview.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with NetworkLoggy {
  late PagingController<int, PushNotification> _pagingController;
  late PushNotificationService _pushNotificationService;

  @override
  void initState() {
    _pagingController =
        PagingController<int, PushNotification>(firstPageKey: 0);
    _pushNotificationService = GetIt.I.get<PushNotificationService>();
    _pushNotificationService.addListener(() => _pagingController.refresh());
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<PushNotification>> _notificationFuture(int offset, int limit) =>
      _pushNotificationService.getAll(offset: offset, limit: limit);

  Widget buildNoNotificationsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.notifications_none_outlined,
      title: AppLocalizations.of(context)!.noNotifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
      ),
      body: NotificationPagedListView(
        notificationFuture: _notificationFuture,
        noNotificationsFound: buildNoNotificationsFound(context),
        pageSize: 10,
        pagingController: _pagingController,
      ),
    );
  }
}
