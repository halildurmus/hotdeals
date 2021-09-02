import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../chat/message_arguments.dart';
import '../chat/message_screen.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';

class NotificationOverlayItem extends StatelessWidget {
  const NotificationOverlayItem(this.notification, {Key? key})
      : super(key: key);

  final PushNotification notification;

  Future<void> _onTap(BuildContext context) async {
    final String _docId = notification.object;
    final MyUser _user = context.read<UserControllerImpl>().user!;
    String _user2Id;
    if (_user.uid == _docId.split('_')[0]) {
      _user2Id = _docId.split('_')[1];
    } else {
      _user2Id = _docId.split('_')[0];
    }

    final MyUser user2 =
        await GetIt.I.get<SpringService>().getUserByUid(uid: _user2Id);

    Navigator.of(context).pushNamed(
      MessageScreen.routeName,
      arguments: MessageArguments(docId: _docId, user2: user2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        child: ListTile(
          onTap: () => _onTap(context),
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
