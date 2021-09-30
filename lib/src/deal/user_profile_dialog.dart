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
import 'report_user_dialog.dart';

typedef Json = Map<String, dynamic>;

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({Key? key, required this.user}) : super(key: key);

  final MyUser user;

  @override
  _UserProfileDialogState createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  MyUser? loggedInUser;
  late final FirestoreService firestoreService;
  late final SpringService springService;

  @override
  void initState() {
    firestoreService = GetIt.I.get<FirestoreService>();
    springService = GetIt.I.get<SpringService>();
    loggedInUser = context.read<UserControllerImpl>().user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final MyUser user = widget.user;

    Future<void> onPressedReport() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
            ReportUserDialog(reportedUserId: user.id!),
      ).then((_) => Navigator.of(context).pop());
    }

    Widget buildButtons() {
      final List<String> usersArray = ChatUtil.getUsersArray(
          user1Uid: loggedInUser!.uid, user2Uid: user.uid);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            width: deviceWidth / 2.8,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: onPressedReport,
                style: ElevatedButton.styleFrom(
                  primary: theme.colorScheme.secondary,
                ),
                child: Text(AppLocalizations.of(context)!.reportUser),
              ),
            ),
          ),
          FutureBuilder<QuerySnapshot<Json>>(
            future: GetIt.I
                .get<FirestoreService>()
                .getMessageDocument(usersArray: usersArray),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Json>> snapshot) {
              VoidCallback? onTap;

              if (snapshot.hasData) {
                final List<DocumentSnapshot<Json>> _items = snapshot.data!.docs;
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

              return Container(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                width: deviceWidth / 2.8,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      primary: theme.colorScheme.secondary,
                    ),
                    child: Text(AppLocalizations.of(context)!.sendMessage),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    Widget buildJoinedSection() {
      return Row(
        children: <Widget>[
          Icon(Icons.date_range,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey
                  : theme.primaryColor,
              size: 18),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!
                .joined(DateFormat.yMMM().format(user.createdAt!)),
            style: textTheme.bodyText2!.copyWith(
                color: theme.brightness == Brightness.dark ? Colors.grey : null,
                fontSize: 13),
          ),
        ],
      );
    }

    Widget buildNumberOfPostedDealsSection() {
      return Row(
        children: <Widget>[
          Icon(Icons.local_offer,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey
                  : theme.primaryColor,
              size: 18),
          const SizedBox(width: 6),
          FutureBuilder<int?>(
            future:
                springService.getNumberOfDealsPostedByUser(userId: user.id!),
            builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
              String postedDeals = '...';

              if (snapshot.hasData) {
                postedDeals = snapshot.data!.toString();
              }

              return Text(
                '$postedDeals ${AppLocalizations.of(context)!.dealsPosted}',
                style: textTheme.bodyText2!.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey
                        : null,
                    fontSize: 13),
              );
            },
          ),
        ],
      );
    }

    Widget buildNumberOfPostedCommentsSection() {
      return Row(
        children: <Widget>[
          Icon(Icons.chat,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey
                  : theme.primaryColor,
              size: 18),
          const SizedBox(width: 6),
          FutureBuilder<int?>(
            future:
                springService.getNumberOfCommentsPostedByUser(userId: user.id!),
            builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
              String postedComments = '...';

              if (snapshot.hasData) {
                postedComments = snapshot.data!.toString();
              }

              return Text(
                '$postedComments ${AppLocalizations.of(context)!.commentsPosted}',
                style: textTheme.bodyText2!.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey
                        : null,
                    fontSize: 13),
              );
            },
          ),
        ],
      );
    }

    Widget buildContent() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                  children: <Widget>[
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.aboutUser,
              style: textTheme.headline6!.copyWith(fontSize: 16),
            ),
            const Divider(),
            const SizedBox(height: 10),
            buildContent(),
          ],
        ),
      ),
    );
  }
}
