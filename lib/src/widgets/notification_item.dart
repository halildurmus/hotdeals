import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/my_user.dart';
import '../models/notification_verb.dart';
import '../models/push_notification.dart';
import '../services/spring_service.dart';
import '../utils/date_time_util.dart';

class NotificationItem extends StatelessWidget with NetworkLoggy {
  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  final PushNotification notification;
  final VoidCallback onTap;

  Widget buildErrorWidget() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shrinkWrap: true,
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return Text(
          AppLocalizations.of(context)!.anErrorOccurred,
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Widget buildNotificationCard(BuildContext context, MyUser user) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      color: !notification.isRead ? theme.primaryColor.withOpacity(.1) : null,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
          isThreeLine: notification.verb == NotificationVerb.comment,
          leading: CachedNetworkImage(
            imageUrl: user.avatar!,
            imageBuilder:
                (BuildContext ctx, ImageProvider<Object> imageProvider) =>
                    CircleAvatar(backgroundImage: imageProvider),
            placeholder: (BuildContext context, String url) =>
                const CircleAvatar(),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(
              text: TextSpan(
                text: user.nickname,
                style:
                    textTheme.bodyText2!.copyWith(fontWeight: FontWeight.w500),
                children: [
                  if (notification.verb == NotificationVerb.comment)
                    TextSpan(
                      text: AppLocalizations.of(context)!.commentedOnYourPost,
                      style: textTheme.bodyText2,
                    ),
                ],
              ),
            ),
          ),
          subtitle: notification.verb == NotificationVerb.comment
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${notification.message!}"',
                      style: textTheme.bodyText2!.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateTimeUtil.formatDateTime(
                        notification.createdAt!,
                        useShortMessages: false,
                      ),
                    ),
                  ],
                )
              : Text(
                  DateTimeUtil.formatDateTime(
                    notification.createdAt!,
                    useShortMessages: false,
                  ),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyUser>(
      future: GetIt.I.get<SpringService>().getUserById(id: notification.actor),
      builder: (BuildContext context, AsyncSnapshot<MyUser> snapshot) {
        if (snapshot.hasData) {
          final MyUser user = snapshot.data!;

          return buildNotificationCard(context, user);
        } else if (snapshot.hasError) {
          loggy.error(snapshot.error, snapshot.error);

          return buildErrorWidget();
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
