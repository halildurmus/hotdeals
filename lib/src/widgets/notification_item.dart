import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../app_localizations.dart';
import '../models/my_user.dart';
import '../models/notification_verb.dart';
import '../models/push_notification.dart';
import '../services/spring_service.dart';
import '../settings/settings_controller.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key? key,
    required this.onTap,
    required this.notification,
  }) : super(key: key);

  final void Function() onTap;
  final PushNotification notification;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return FutureBuilder<MyUser>(
      future: GetIt.I.get<SpringService>().getUserById(id: notification.actor),
      builder: (BuildContext context, AsyncSnapshot<MyUser> snapshot) {
        if (snapshot.hasData) {
          final MyUser user = snapshot.data!;

          return Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: !notification.isRead
                ? theme.primaryColor.withOpacity(.1)
                : null,
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
                      style: textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      children: <TextSpan>[
                        if (notification.verb == NotificationVerb.comment)
                          TextSpan(
                            text: AppLocalizations.of(context)!
                                .commentedOnYourPost,
                            style: textTheme.bodyText2,
                          ),
                      ],
                    ),
                  ),
                ),
                subtitle: notification.verb == NotificationVerb.comment
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '"${notification.message!}"',
                            style: textTheme.bodyText2!.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            timeago.format(
                              notification.createdAt!,
                              locale: GetIt.I
                                  .get<SettingsController>()
                                  .locale
                                  .languageCode,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        timeago.format(
                          notification.createdAt!,
                          locale: GetIt.I
                              .get<SettingsController>()
                              .locale
                              .languageCode,
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
        } else if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.stackTrace);

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

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
