import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/comment.dart';
import '../models/my_user.dart';
import '../services/spring_service.dart';
import '../settings/settings_controller.dart';
import 'user_profile_dialog.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({Key? key, required this.comment}) : super(key: key);

  final Comment comment;

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  Future<void> _onUserTap(MyUser user) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => UserProfileDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final comment = widget.comment;

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
            children: [
              FutureBuilder<MyUser>(
                future: GetIt.I
                    .get<SpringService>()
                    .getUserById(id: comment.postedBy!),
                builder:
                    (BuildContext context, AsyncSnapshot<MyUser> snapshot) {
                  String avatar = 'http://www.gravatar.com/avatar';
                  String nickname = '...';

                  if (snapshot.hasData) {
                    avatar = snapshot.data!.avatar!;
                    nickname = snapshot.data!.nickname!;
                  } else if (snapshot.hasError) {
                    nickname = AppLocalizations.of(context)!.anErrorOccurred;
                  }

                  return GestureDetector(
                    onTap: () => _onUserTap(snapshot.data!),
                    child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: avatar,
                          imageBuilder: (BuildContext ctx,
                                  ImageProvider<Object> imageProvider) =>
                              CircleAvatar(
                                  backgroundImage: imageProvider, radius: 16),
                          placeholder: (BuildContext context, String url) =>
                              const CircleAvatar(radius: 16),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          nickname,
                          style: textTheme.subtitle2,
                        )
                      ],
                    ),
                  );
                },
              ),
              Text(
                timeago.format(
                  comment.createdAt!,
                  locale:
                      '${GetIt.I.get<SettingsController>().locale.languageCode}_short',
                ),
                style: textTheme.bodyText2!.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(comment.message)
        ],
      ),
    );
  }
}
