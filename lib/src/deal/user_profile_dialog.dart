import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../chat/message_arguments.dart';
import '../chat/message_screen.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/firestore_service.dart';
import '../services/spring_service.dart';
import '../utils/chat_util.dart';
import '../utils/error_indicator_util.dart';
import 'report_user_dialog.dart';

typedef Json = Map<String, dynamic>;

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _UserProfileDialogState createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  MyUser? loggedInUser;
  late final FirestoreService firestoreService;
  late final SpringService springService;
  late final Future<MyUser> userFuture;
  late final Future<int?> postedCommentsFuture;
  late final Future<int?> postedDealsFuture;
  late MyUser user;
  late int postedCommentsCount;
  late int postedDealsCount;

  @override
  void initState() {
    loggedInUser = context.read<UserControllerImpl>().user;
    firestoreService = GetIt.I.get<FirestoreService>();
    springService = GetIt.I.get<SpringService>();
    userFuture = springService.getUserById(id: widget.userId);
    postedCommentsFuture =
        springService.getNumberOfCommentsPostedByUser(userId: widget.userId);
    postedDealsFuture =
        springService.getNumberOfDealsPostedByUser(userId: widget.userId);
    super.initState();
  }

  Future<void> onPressedReport() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          ReportUserDialog(reportedUserId: user.id!),
    ).then((_) => Navigator.of(context).pop());
  }

  Widget buildCircularProgressIndicator() {
    final theme = Theme.of(context);

    return SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      ),
    );
  }

  Widget buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ErrorIndicatorUtil.buildFirstPageError(
        context,
        onTryAgain: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget buildButtons() {
      final List<String> usersArray = ChatUtil.getUsersArray(
          user1Uid: loggedInUser!.uid, user2Uid: user.uid);

      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onPressedReport,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(deviceWidth * .35, 50),
                primary: theme.colorScheme.secondary,
              ),
              child: Text(AppLocalizations.of(context)!.reportUser),
            ),
            FutureBuilder<QuerySnapshot<Json>>(
              future: GetIt.I
                  .get<FirestoreService>()
                  .getMessageDocument(usersArray: usersArray),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Json>> snapshot) {
                VoidCallback? onTap;

                if (snapshot.hasData) {
                  final List<DocumentSnapshot<Json>> _items =
                      snapshot.data!.docs;
                  onTap = () async {
                    if (_items.isEmpty) {
                      await firestoreService.createMessageDocument(
                          user1Uid: loggedInUser!.uid, user2Uid: user.uid);
                    }

                    final String conversationId = ChatUtil.getConversationID(
                        user1Uid: loggedInUser!.uid, user2Uid: user.uid);

                    Navigator.of(context).pushNamed(
                      MessageScreen.routeName,
                      arguments: MessageArguments(
                        docId: conversationId,
                        user2: user,
                      ),
                    );
                  };
                }

                return ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(deviceWidth * .35, 50),
                    primary: theme.colorScheme.secondary,
                  ),
                  child: Text(AppLocalizations.of(context)!.sendMessage),
                );
              },
            ),
          ],
        ),
      );
    }

    Widget buildJoinedSection() {
      return Row(
        children: [
          Icon(
            Icons.date_range,
            color: theme.brightness == Brightness.dark
                ? Colors.grey
                : theme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!
                .joined(DateFormat.yMMM().format(user.createdAt!)),
            style: textTheme.bodyText2!.copyWith(
              color: theme.brightness == Brightness.dark ? Colors.grey : null,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    Widget buildNumberOfPostedDealsSection() {
      return Row(
        children: [
          Icon(
            Icons.local_offer,
            color: theme.brightness == Brightness.dark
                ? Colors.grey
                : theme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$postedDealsCount ${AppLocalizations.of(context)!.dealsPosted}',
            style: textTheme.bodyText2!.copyWith(
              color: theme.brightness == Brightness.dark ? Colors.grey : null,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    Widget buildNumberOfPostedCommentsSection() {
      return Row(
        children: [
          Icon(
            Icons.chat,
            color: theme.brightness == Brightness.dark
                ? Colors.grey
                : theme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$postedCommentsCount ${AppLocalizations.of(context)!.commentsPosted}',
            style: textTheme.bodyText2!.copyWith(
              color: theme.brightness == Brightness.dark ? Colors.grey : null,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    Widget buildUserDetails() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: user.avatar!,
                  imageBuilder: (BuildContext ctx,
                          ImageProvider<Object> imageProvider) =>
                      CircleAvatar(backgroundImage: imageProvider, radius: 30),
                  placeholder: (BuildContext context, String url) =>
                      const CircleAvatar(radius: 30),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname!,
                      style: textTheme.headline6!.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    buildJoinedSection(),
                    const SizedBox(height: 8),
                    buildNumberOfPostedDealsSection(),
                    const SizedBox(height: 8),
                    buildNumberOfPostedCommentsSection(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (loggedInUser != null && loggedInUser?.id != user.id)
              buildButtons(),
          ],
        ),
      );
    }

    Widget buildFutureBuilder() {
      return FutureBuilder<dynamic>(
        future: Future.wait<dynamic>(
          [userFuture, postedCommentsFuture, postedDealsFuture],
        ),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data![0];
            postedCommentsCount = snapshot.data![1];
            postedDealsCount = snapshot.data![2];

            return buildUserDetails();
          } else if (snapshot.hasError) {
            return buildErrorWidget();
          }

          return buildCircularProgressIndicator();
        },
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.aboutUser,
              style: textTheme.headline6!.copyWith(fontSize: 16),
            ),
            const Divider(),
            const SizedBox(height: 10),
            buildFutureBuilder(),
          ],
        ),
      ),
    );
  }
}
