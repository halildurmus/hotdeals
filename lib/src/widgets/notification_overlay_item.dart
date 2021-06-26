import 'package:flutter/material.dart';

import '../models/push_notification.dart';

class NotificationOverlayItem extends StatelessWidget {
  const NotificationOverlayItem(this.notification, {Key? key})
      : super(key: key);

  final PushNotification notification;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        child: ListTile(
          leading: notification.avatar != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(notification.avatar!),
                )
              : null,
          title: Text(notification.title),
          subtitle: Text(notification.body),
          // trailing: IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.reply),
          // ),
        ),
      ),
    );
  }
}
