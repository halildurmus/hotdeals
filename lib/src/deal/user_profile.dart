import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../chat/message_arguments.dart';
import '../chat/message_screen.dart';
import '../models/my_user.dart';
import '../models/report.dart';
import '../models/user_controller_impl.dart';
import '../services/firestore_service.dart';
import '../services/spring_service.dart';
import '../utils/chat_util.dart';
import '../widgets/loading_dialog.dart';

typedef Json = Map<String, dynamic>;

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required this.user}) : super(key: key);

  final MyUser user;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  MyUser? loggedInUser;
  late FirestoreService firestoreService;
  late SpringService springService;
  late TextEditingController messageController;
  bool harassingCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;

  @override
  void initState() {
    firestoreService = GetIt.I.get<FirestoreService>();
    springService = GetIt.I.get<SpringService>();
    loggedInUser = context.read<UserControllerImpl>().user;
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final MyUser user = widget.user;

    Future<void> sendReport(BuildContext context) async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final Report report = Report(
        reportedBy: loggedInUser!.id!,
        reportedUser: user.id,
        reasons: <String>[
          if (harassingCheckbox) 'Harassing',
          if (spamCheckbox) 'Spam',
          if (otherCheckbox) 'Other'
        ],
        message:
            messageController.text.isNotEmpty ? messageController.text : null,
      );

      final Report? sentReport =
          await GetIt.I.get<SpringService>().sendReport(report: report);
      print(sentReport);

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (sentReport != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.successfullyReportedUser)),
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

    Future<void> onPressedReport() async {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.reportUser,
                        style: textTheme.headline6,
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        title: Text(AppLocalizations.of(context)!.harassing),
                        value: harassingCheckbox,
                        onChanged: (bool? newValue) {
                          setState(() {
                            harassingCheckbox = newValue!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text(AppLocalizations.of(context)!.spam),
                        value: spamCheckbox,
                        onChanged: (bool? newValue) {
                          setState(() {
                            spamCheckbox = newValue!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text(AppLocalizations.of(context)!.other),
                        value: otherCheckbox,
                        onChanged: (bool? newValue) {
                          setState(() {
                            otherCheckbox = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintStyle: textTheme.bodyText2!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.grey),
                          hintText: AppLocalizations.of(context)!
                              .enterSomeDetailsAboutReport,
                        ),
                        minLines: 1,
                        maxLines: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: deviceWidth,
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            onPressed: harassingCheckbox ||
                                    spamCheckbox ||
                                    otherCheckbox
                                ? () => sendReport(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              primary: theme.colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child:
                                Text(AppLocalizations.of(context)!.reportUser),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
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
              void Function()? onTap;

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
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());
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
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());
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
            if (loggedInUser != null) buildButtons(),
          ],
        ),
      );
    }

    return Padding(
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
    );
  }
}
