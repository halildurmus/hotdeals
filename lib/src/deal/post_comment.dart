import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../notification/push_notification.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_dialog.dart';

class PostComment extends StatefulWidget {
  const PostComment({required this.deal, Key? key}) : super(key: key);

  final Deal deal;

  @override
  _PostCommentState createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> with UiLoggy {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late MyUser? user;
  late TextEditingController commentController;
  late FocusNode commentFocusNode;

  @override
  void initState() {
    user = context.read<UserController>().user;
    commentController = TextEditingController();
    commentFocusNode = FocusNode()..requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;

    Future<void> onPressed() async {
      if (commentController.text.isEmpty) {
        return;
      }

      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final comment = Comment(message: commentController.text);
      final postedComment = await GetIt.I
          .get<APIRepository>()
          .postComment(dealId: widget.deal.id!, comment: comment);

      // Send push notification to the poster if the commentator is not
      // the poster.
      if (user!.id! != widget.deal.postedBy) {
        final poster = await GetIt.I
            .get<APIRepository>()
            .getUserExtendedById(id: widget.deal.postedBy!);

        final notification = PushNotification(
          titleLocKey: 'comment_title',
          titleLocArgs: [user!.nickname!],
          body: comment.message,
          actor: user!.id!,
          verb: NotificationVerb.comment,
          object: widget.deal.id!,
          message: comment.message,
          uid: poster.uid,
          avatar: user!.avatar!,
          tokens: poster.fcmTokens!.values.toList(),
        );

        final result = await GetIt.I
            .get<APIRepository>()
            .sendPushNotification(notification: notification);
        if (result) {
          loggy.debug('Push notification sent to: ${poster.nickname}');
        }
      }

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (postedComment != null) {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.circleCheck, size: 20),
          text: l(context).postedYourComment,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
      } else {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.circleExclamation, size: 20),
          text: l(context).anErrorOccurred,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    Widget buildPostButton() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ElevatedButton(
            onPressed:
                (_formKey.currentState?.validate() ?? false) ? onPressed : null,
            style: ElevatedButton.styleFrom(
              fixedSize: Size(deviceWidth, 45),
              primary: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(l(context).postComment),
          ),
        );

    Widget buildForm() => Form(
          key: _formKey,
          child: TextFormField(
            controller: commentController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorMaxLines: 2,
              hintStyle: textTheme.bodyText2!.copyWith(
                  color: theme.brightness == Brightness.light
                      ? Colors.black54
                      : Colors.grey),
              hintText: l(context).enterYourComment,
            ),
            focusNode: commentFocusNode,
            minLines: 4,
            maxLines: 30,
            maxLength: 500,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            onChanged: (text) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l(context).nicknameMustBe;
              }

              return null;
            },
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l(context).postAComment,
            style: textTheme.headline6,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildForm(),
                const SizedBox(height: 10),
                buildPostButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
