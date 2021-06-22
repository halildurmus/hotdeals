import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/user_controller_impl.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem(
      {Key? key, required this.onTap, required this.notification})
      : super(key: key);

  final void Function() onTap;
  final PushNotification notification;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final MyUser user =
        Provider.of<UserControllerImpl>(context, listen: false).user!;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: !notification.isRead ? theme.primaryColor.withOpacity(.1) : null,
      child: InkWell(
        onTap: onTap,
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
          isThreeLine: true,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatar!),
          ),
          title: Row(
            children: <Widget>[
              Text(
                'MrNobody123',
                style: textTheme.bodyText2!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(notification.title, style: textTheme.bodyText2),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                notification.body,
                style: textTheme.bodyText2!.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(timeago.format(notification.createdAt!, locale: 'en')),
            ],
          ),
          trailing: !notification.isRead
              ? Text(
                  '•',
                  style: TextStyle(
                      color: theme.colorScheme.secondary, fontSize: 36),
                )
              : null,
        ),
      ),
    );
  }
}
