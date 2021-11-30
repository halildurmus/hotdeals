import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../utils/date_time_util.dart';
import '../widgets/sign_in_dialog.dart';
import '../widgets/user_profile_dialog.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({Key? key, required this.comment}) : super(key: key);

  final Comment comment;

  Future<void> _onUserTap(BuildContext context, String userId) async {
    return showDialog<void>(
      context: context,
      builder: (context) => UserProfileDialog(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final poster = comment.poster!;
    final MyUser? user = context.read<UserController>().user;

    Widget buildUserDetails() {
      return GestureDetector(
        onTap: () => user == null
            ? GetIt.I.get<SignInDialog>().showSignInDialog(context)
            : _onUserTap(context, poster.id!),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: poster.avatar!,
              imageBuilder: (ctx, imageProvider) =>
                  CircleAvatar(backgroundImage: imageProvider, radius: 16),
              placeholder: (context, url) => const CircleAvatar(radius: 16),
            ),
            const SizedBox(width: 8),
            Text(poster.nickname!, style: textTheme.subtitle2)
          ],
        ),
      );
    }

    Widget buildCommentDateTime() {
      return Text(
        DateTimeUtil.formatDateTime(comment.createdAt!),
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
            children: [
              buildUserDetails(),
              buildCommentDateTime(),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(comment.message)
        ],
      ),
    );
  }
}
