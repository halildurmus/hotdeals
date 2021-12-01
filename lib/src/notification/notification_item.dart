import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/my_user.dart';
import '../models/notification_verb.dart';
import '../models/push_notification.dart';
import '../services/spring_service.dart';
import '../utils/date_time_util.dart';
import '../utils/localization_util.dart';

class NotificationItem extends StatefulWidget {
  const NotificationItem({
    Key? key,
    required this.isSelectionMode,
    required this.isSelected,
    required this.notification,
    required this.onLongPress,
    required this.onTap,
  }) : super(key: key);

  final bool isSelectionMode;
  final bool isSelected;
  final PushNotification notification;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> with NetworkLoggy {
  late Future<MyUser> _userFuture;

  @override
  void initState() {
    _userFuture = GetIt.I
        .get<SpringService>()
        .getUserById(id: widget.notification.actor!);
    super.initState();
  }

  Widget _buildListTile(MyUser user) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget _buildLeading() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSelectionMode)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: theme.primaryColor,
                ),
              ],
            ),
          if (widget.isSelectionMode) const SizedBox(width: 16),
          CachedNetworkImage(
            imageUrl: user.avatar!,
            imageBuilder: (ctx, imageProvider) =>
                CircleAvatar(backgroundImage: imageProvider),
            placeholder: (context, url) => const CircleAvatar(),
          ),
        ],
      );
    }

    Widget _buildTitle() {
      return RichText(
        text: TextSpan(
          text: user.nickname,
          style: textTheme.bodyText2!.copyWith(fontWeight: FontWeight.w500),
          children: [
            if (widget.notification.verb == NotificationVerb.comment)
              TextSpan(
                text: l(context).commentedOnYourPost,
                style: textTheme.bodyText2,
              ),
          ],
        ),
      );
    }

    Widget _buildSubtitle() {
      if (widget.notification.verb == NotificationVerb.message) {
        return Text(
          DateTimeUtil.formatDateTime(
            widget.notification.createdAt!,
            useShortMessages: false,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${widget.notification.message!}"',
            style: textTheme.bodyText2!
                .copyWith(color: theme.colorScheme.secondary),
          ),
          const SizedBox(height: 5),
          Text(
            DateTimeUtil.formatDateTime(
              widget.notification.createdAt!,
              useShortMessages: false,
            ),
          ),
        ],
      );
    }

    Widget _buildTrailing() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: theme.brightness == Brightness.dark
                ? theme.primaryColor
                : theme.primaryColorLight,
            radius: 6,
          ),
        ],
      );
    }

    return ListTile(
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      isThreeLine: widget.notification.verb == NotificationVerb.comment,
      leading: _buildLeading(),
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      trailing: widget.notification.isRead ? null : _buildTrailing(),
    );
  }

  Widget _buildCard(BuildContext context, MyUser user) {
    final theme = Theme.of(context);

    return Card(
      color: widget.isSelected
          ? theme.primaryColor.withOpacity(.2)
          : !widget.notification.isRead
              ? theme.primaryColor.withOpacity(.1)
              : null,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: _buildListTile(user),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        l(context).anErrorOccurred,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyUser>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final MyUser user = snapshot.data!;

          return _buildCard(context, user);
        } else if (snapshot.hasError) {
          loggy.error(snapshot.error, snapshot.error);

          return _buildErrorWidget(context);
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 25),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
