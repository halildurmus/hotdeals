import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/push_notification.dart';
import '../services/push_notification_service.dart';
import '../widgets/notification_item.dart';

class MyNotifications extends StatefulWidget {
  const MyNotifications({Key? key}) : super(key: key);

  @override
  _MyNotificationsState createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications> with NetworkLoggy {
  late PushNotificationService pushNotificationService;

  @override
  void initState() {
    pushNotificationService = GetIt.I.get<PushNotificationService>();
    super.initState();
  }

  Widget buildNotifications(List<PushNotification> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: notifications.length,
      itemBuilder: (BuildContext context, int index) {
        final notification = notifications.elementAt(index);

        Future<void> onTap() async {
          if (notification.isRead) {
            return;
          }

          notification.isRead = true;
          await pushNotificationService.update(notification);
        }

        return NotificationItem(onTap: onTap, notification: notification);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pushNotificationService,
      builder: (BuildContext context, Widget? child) {
        return FutureBuilder<List<PushNotification>>(
          future: pushNotificationService.getAll(),
          builder: (BuildContext context,
              AsyncSnapshot<List<PushNotification>> snapshot) {
            if (snapshot.hasData) {
              final notifications = snapshot.data!;

              if (notifications.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.noNotifications),
                );
              }

              return buildNotifications(notifications);
            } else if (snapshot.hasError) {
              loggy.error(snapshot.error, snapshot.error);

              return Center(
                child: Text(AppLocalizations.of(context)!.anErrorOccurred),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
