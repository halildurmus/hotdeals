import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

import '../models/push_notification.dart';
import '../services/sqlite_service.dart';
import '../widgets/notification_item.dart';

class MyNotifications extends StatefulWidget {
  const MyNotifications({Key? key}) : super(key: key);

  @override
  _MyNotificationsState createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications> {
  late SQLiteService<PushNotification> sqliteService;

  @override
  void initState() {
    sqliteService = GetIt.I.get<SQLiteService<PushNotification>>();
    super.initState();
  }

  Future<bool> sendFcmMessage(String title, String message) async {
    try {
      const String url = 'https://fcm.googleapis.com/fcm/send';
      final Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization":
            "key= XXXXX",
      };
      final Map<String, Object> request = {
        'notification': {'title': title, 'body': message},
        'data': {'title': 'FLUTTER_NOTIFICATION_CLICK', 'body': 'COMMENT'},
        'to':
            'e0qYCzDYTkKfvcMA7dPoJW:APA91bF8crh77nuZjIUDDyiNSCgPGO4giq25B6o8Wq9RTPn0-UsyqWuU-KjJE2jwcVx77ygbptnMC_G8wOZ5OQLjlexSznyCfZaTcp5wZcqKb_0GVSwmNPrtnCsUuz29GPhNon1jQoEh'
      };

      final Client client = Client();
      final Response response = await client.post(Uri.parse(url),
          headers: header, body: json.encode(request));
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildNotifications(List<PushNotification> notifications) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: notifications.length,
        itemBuilder: (BuildContext context, int index) {
          final PushNotification notification = notifications.elementAt(index);

          Future<void> onTap() async {
            await sendFcmMessage('1test title', '1test message');
            // if (notification.isRead) {
            //   return;
            // }
            //
            // notification.isRead = true;
            // await sqliteService.update(notification);
          }

          return NotificationItem(onTap: onTap, notification: notification);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox();
        },
      );
    }

    return AnimatedBuilder(
      animation: sqliteService,
      builder: (BuildContext context, Widget? child) {
        return FutureBuilder<List<PushNotification>>(
          future: sqliteService.getAll(),
          builder: (BuildContext context,
              AsyncSnapshot<List<PushNotification>> snapshot) {
            if (snapshot.hasData) {
              final List<PushNotification> notifications = snapshot.data!;

              return buildNotifications(notifications);
            } else if (snapshot.hasError) {
              print(snapshot.error);

              return const Center(child: Text('An error occurred!'));
            }

            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
