import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../chat/message_arguments.dart';
import '../chat/message_screen.dart';
import '../deal/report_user_dialog.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/api_repository.dart';
import '../services/firestore_service.dart';
import '../utils/chat_util.dart';
import '../utils/error_indicator_util.dart';
import '../utils/localization_util.dart';

typedef Json = Map<String, dynamic>;

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({
    Key? key,
    required this.userId,
    this.hideButtons = false,
  }) : super(key: key);

  final String userId;
  final bool hideButtons;

  @override
  _UserProfileDialogState createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  MyUser? loggedInUser;
  late final FirestoreService firestoreService;
  late final APIRepository apiRepository;
  late final Future<MyUser> userFuture;
  late final Future<int?> postedCommentsFuture;
  late final Future<int?> postedDealsFuture;
  late final Future<List<dynamic>> future;
  late MyUser user;
  late int postedCommentsCount;
  late int postedDealsCount;

  @override
  void initState() {
    loggedInUser = context.read<UserController>().user;
    firestoreService = GetIt.I.get<FirestoreService>();
    apiRepository = GetIt.I.get<APIRepository>();
    userFuture = apiRepository.getUserById(id: widget.userId);
    postedCommentsFuture =
        apiRepository.getNumberOfCommentsPostedByUser(userId: widget.userId);
    postedDealsFuture =
        apiRepository.getNumberOfDealsPostedByUser(userId: widget.userId);
    future = Future.wait([userFuture, postedCommentsFuture, postedDealsFuture]);
    super.initState();
  }

  Future<void> _onReportUserPressed() async => showDialog<void>(
        context: context,
        builder: (context) => ReportUserDialog(reportedUserId: user.id!),
      ).then((_) => Navigator.of(context).pop());

  Widget _buildErrorWidget() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ErrorIndicatorUtil.buildFirstPageError(
          context,
          onTryAgain: () => setState(() {}),
        ),
      );

  Widget _buildCircularProgressIndicator() {
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

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade300
        : theme.primaryColor;
    final textStyle = textTheme.bodyText2!.copyWith(
      color: theme.brightness == Brightness.dark ? Colors.grey.shade400 : null,
      fontSize: 13,
    );

    Widget _buildJoinedSection() => Row(
          children: [
            Icon(Icons.date_range, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              l(context).joined(DateFormat.yMMM().format(user.createdAt!)),
              style: textStyle,
            ),
          ],
        );

    Widget _buildNumberOfPostedDealsSection() => Row(
          children: [
            Icon(Icons.local_offer, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              '$postedDealsCount',
              style: textStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(l(context).dealsPosted, style: textStyle),
          ],
        );

    Widget _buildNumberOfPostedCommentsSection() => Row(
          children: [
            Icon(Icons.chat, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              '$postedCommentsCount',
              style: textStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(l(context).commentsPosted, style: textStyle),
          ],
        );

    Widget _buildButtons() {
      final usersArray = ChatUtil.getUsersArray(
          user1Uid: loggedInUser!.uid, user2Uid: user.uid);

      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _onReportUserPressed,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(deviceWidth * .35, 50),
                primary: theme.colorScheme.secondary,
              ),
              child: Text(
                l(context).reportUser,
                textAlign: TextAlign.center,
              ),
            ),
            FutureBuilder<QuerySnapshot<Json>>(
              future: GetIt.I
                  .get<FirestoreService>()
                  .getMessageDocument(usersArray: usersArray),
              builder: (context, snapshot) {
                VoidCallback? onTap;

                if (snapshot.hasData) {
                  final items = snapshot.data!.docs;
                  onTap = () async {
                    if (items.isEmpty) {
                      await firestoreService.createMessageDocument(
                          user1Uid: loggedInUser!.uid, user2Uid: user.uid);
                    }

                    final conversationId = ChatUtil.getConversationID(
                        user1Uid: loggedInUser!.uid, user2Uid: user.uid);
                    final user2 =
                        await apiRepository.getUserByUid(uid: user.uid);

                    Navigator.of(context).pushNamed(
                      MessageScreen.routeName,
                      arguments: MessageArguments(
                        docId: conversationId,
                        user2: user2,
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
                  child: Text(
                    l(context).sendMessage,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    Widget _buildAvatar() => CachedNetworkImage(
          imageUrl: user.avatar!,
          imageBuilder: (ctx, imageProvider) =>
              CircleAvatar(backgroundImage: imageProvider, radius: 30),
          placeholder: (context, url) => const CircleAvatar(radius: 30),
        );

    Widget _buildNickname() => Text(
          user.nickname!,
          style: textTheme.headline6!.copyWith(fontSize: 18),
        );

    Widget _buildUserDetails() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNickname(),
                    const SizedBox(height: 8),
                    _buildJoinedSection(),
                    const SizedBox(height: 8),
                    _buildNumberOfPostedDealsSection(),
                    const SizedBox(height: 8),
                    _buildNumberOfPostedCommentsSection(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!widget.hideButtons &&
                loggedInUser != null &&
                loggedInUser?.id != user.id)
              _buildButtons(),
          ],
        );

    Widget _buildFutureBuilder() => FutureBuilder<List<dynamic>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              user = snapshot.data![0];
              postedCommentsCount = snapshot.data![1];
              postedDealsCount = snapshot.data![2];

              return _buildUserDetails();
            } else if (snapshot.hasError) {
              return _buildErrorWidget();
            }

            return _buildCircularProgressIndicator();
          },
        );

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
              l(context).aboutUser,
              style: textTheme.headline6!.copyWith(fontSize: 16),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFutureBuilder(),
            ),
          ],
        ),
      ),
    );
  }
}
