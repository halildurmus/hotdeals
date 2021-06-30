import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/loading_dialog.dart';

class PostComment extends StatefulWidget {
  const PostComment({Key? key, required this.deal}) : super(key: key);

  final Deal deal;

  @override
  _PostCommentState createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  late MyUser? user;
  late TextEditingController commentController;

  @override
  void initState() {
    user = context.read<UserControllerImpl>().user;
    commentController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final double deviceWidth = MediaQuery.of(context).size.width;

    Future<void> onPressed() async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final Comment comment = Comment(
        dealId: widget.deal.id!,
        postedBy: user!.id!,
        message: commentController.text,
      );

      final Comment? postedComment =
          await GetIt.I.get<SpringService>().postComment(comment: comment);
      print(postedComment);

      // Send push notification to the poster if the commentator is not
      // the poster.
      if (user!.id! != widget.deal.postedBy) {
        final MyUser poster = await GetIt.I
            .get<SpringService>()
            .getUserById(id: widget.deal.postedBy!);

        final PushNotification notification = PushNotification(
          title:
              '${poster.nickname} ${AppLocalizations.of(context)!.commentedOnYourPost}',
          body: comment.message,
          actor: user!.id!,
          verb: 'comment',
          object: widget.deal.id!,
          message: comment.message,
          uid: poster.id,
          avatar: poster.avatar,
        );

        final bool result = await GetIt.I
            .get<SpringService>()
            .sendPushNotification(
                notification: notification, tokens: poster.fcmTokens!);

        if (result) {
          print('Push notification sent to: ${poster.nickname}');
        }
      }

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (postedComment != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.postedYourComment),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.anErrorOccurred),
          ),
        );
      }
    }

    Widget buildPostButton() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: deviceWidth,
        child: SizedBox(
          height: 45,
          child: ElevatedButton(
            onPressed: commentController.text.isEmpty ? null : onPressed,
            style: ElevatedButton.styleFrom(
              primary: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.postComment),
          ),
        ),
      );
    }

    Widget buildForm() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: commentController,
              onChanged: (String? text) {
                setState(() {});
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintStyle: textTheme.bodyText2!.copyWith(
                    color: theme.brightness == Brightness.light
                        ? Colors.black54
                        : Colors.grey),
                hintText: AppLocalizations.of(context)!.enterYourComment,
              ),
              minLines: 4,
              maxLines: 30,
            ),
            const SizedBox(height: 10),
            buildPostButton(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(AppLocalizations.of(context)!.postAComment,
              style: textTheme.headline6),
          const SizedBox(height: 20),
          buildForm(),
        ],
      ),
    );
  }
}
