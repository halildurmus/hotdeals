import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/comment.dart';
import '../models/my_user.dart';
import '../services/spring_service.dart';
import '../settings/settings_controller.dart';
import 'user_profile_dialog.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({Key? key, required this.comment}) : super(key: key);

  final Comment comment;

  Future<void> _onUserTap(BuildContext context, String userId) async {
    final MyUser user =
        await GetIt.I.get<SpringService>().getUserById(id: userId);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => UserProfileDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final poster = comment.poster!;

    Widget buildUserDetails() {
      return GestureDetector(
        onTap: () => _onUserTap(context, poster.id!),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: poster.avatar!,
              imageBuilder:
                  (BuildContext ctx, ImageProvider<Object> imageProvider) =>
                      CircleAvatar(backgroundImage: imageProvider, radius: 16),
              placeholder: (BuildContext context, String url) =>
                  const CircleAvatar(radius: 16),
            ),
            const SizedBox(width: 8.0),
            Text(poster.nickname!, style: textTheme.subtitle2)
          ],
        ),
      );
    }

    Widget buildCommentDateTime() {
      return Text(
        timeago.format(
          comment.createdAt!,
          locale:
              '${GetIt.I.get<SettingsController>().locale.languageCode}_short',
        ),
        style: textTheme.bodyText2!.copyWith(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.brightness == Brightness.light
            ? Colors.grey.shade200
            : Colors.black26,
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [buildUserDetails(), buildCommentDateTime()],
          ),
          const SizedBox(height: 10),
          SelectableText(comment.message)
        ],
      ),
    );
  }
}
