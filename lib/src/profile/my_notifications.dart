import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/push_notification.dart';
import '../services/push_notification_service.dart';
import '../widgets/error_indicator.dart';
import 'notification_paged_listview.dart';

class MyNotifications extends StatefulWidget {
  const MyNotifications({Key? key}) : super(key: key);

  @override
  _MyNotificationsState createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications> with NetworkLoggy {
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
    final deviceHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: deviceHeight * .5,
      child: ErrorIndicator(
        icon: Icons.notifications_none_outlined,
        title: AppLocalizations.of(context)!.noNotifications,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationPagedListView(
      notificationFuture: _notificationFuture,
      noNotificationsFound: buildNoNotificationsFound(context),
      pageSize: 8,
      pagingController: _pagingController,
    );
  }
}
