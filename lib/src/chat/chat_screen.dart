import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/firestore_service.dart';
import '../services/spring_service.dart';
import '../utils/chat_util.dart';
import '../utils/date_time_util.dart';
import '../utils/error_indicator_util.dart';
import 'blocked_users.dart';
import 'message_arguments.dart';
import 'message_screen.dart';

enum _ChatPopup { blockedUsers }

typedef Json = Map<String, dynamic>;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  static const String routeName = '/chats';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late MyUser? _user;

  @override
  void initState() {
    _user = Provider.of<UserControllerImpl>(context, listen: false).user;
    super.initState();
  }

  Widget buildErrorWidget() {
    return ErrorIndicatorUtil.buildFirstPageError(
      context,
      onTryAgain: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;

    Future<void> _onRefresh() async {
      setState(() {});

      if (mounted) {
        setState(() {});
      }
    }

    Widget _buildSignIn() {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Icon(
                FontAwesomeIcons.comment,
                color: theme.primaryColor,
                size: 120,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.youNeedToSignIn,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.youNeedToSignInToSee,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildNoChats() {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Icon(
                FontAwesomeIcons.comment,
                color: theme.primaryColor,
                size: 120,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noChats,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.noActiveConversations,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildCircularProgressIndicator() {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    Widget _buildBlockedText() {
      return Row(
        children: [
          Icon(Icons.error, size: 18, color: theme.errorColor),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.youCannotChatWithThisUser,
            style: TextStyle(
              color: theme.errorColor,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      );
    }

    Widget _buildFileText(String fileName) {
      return Row(
        children: [
          Icon(
            Icons.description,
            color: theme.primaryColorLight,
            size: 18,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: deviceWidth * .55,
            child: Text(
              fileName,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ),
          ),
        ],
      );
    }

    Widget _buildImageText() {
      return Row(
        children: [
          Icon(
            FontAwesomeIcons.solidImage,
            color: theme.primaryColorLight,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.image,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          ),
        ],
      );
    }

    Widget _buildMessageText(String text) {
      return SizedBox(
        width: deviceWidth * .55,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ),
      );
    }

    Widget _buildUserAvatar(String avatarURL) {
      return CachedNetworkImage(
        imageUrl: avatarURL,
        imageBuilder: (BuildContext ctx, ImageProvider<Object> imageProvider) =>
            CircleAvatar(backgroundImage: imageProvider, radius: 24),
        placeholder: (BuildContext context, String url) =>
            const CircleAvatar(radius: 24),
      );
    }

    Widget _buildUserNickname(String nickname) {
      return SizedBox(
        width: deviceWidth * .55,
        child: Text(
          nickname,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    Widget _buildMessageTime(DateTime createdAt, bool isRead) {
      return Text(
        DateTimeUtil.formatDateTime(createdAt),
        style: TextStyle(
          color: isRead ? Colors.grey : theme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    Widget _buildUnreadIndicator() {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: CircleAvatar(
          backgroundColor: theme.brightness == Brightness.dark
              ? theme.primaryColor
              : theme.primaryColorLight,
          radius: 6,
        ),
      );
    }

    Widget _buildMessage(
        String docId, Json lastMessage, MyUser user, MyUser user2) {
      final _lastMessageIsFile = lastMessage['type'] == 'file';
      final _lastMessageIsImage = lastMessage['type'] == 'image';
      final _sentBy = lastMessage['author']['id'] as String;
      bool _isMessageSeen;
      if (_sentBy != _user!.uid) {
        _isMessageSeen = (lastMessage['status'] as String) == 'seen';
      } else {
        _isMessageSeen = true;
      }
      final bool _isUserBlocked = user.blockedUsers!.contains(user2.uid);
      final DateTime _createdAt = DateTime.fromMillisecondsSinceEpoch(
        lastMessage['createdAt'] as int,
      );

      return InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          MessageScreen.routeName,
          arguments: MessageArguments(
            docId: docId,
            user2: user2,
          ),
        ),
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: Container(
          color: _isMessageSeen
              ? Colors.transparent
              : theme.primaryColor.withOpacity(.2),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildUserAvatar(user2.avatar!),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserNickname(user2.nickname!),
                      const SizedBox(height: 4),
                      if (_isUserBlocked)
                        _buildBlockedText()
                      else if (_lastMessageIsFile)
                        _buildFileText(lastMessage['name'] as String)
                      else if (_lastMessageIsImage)
                        _buildImageText()
                      else
                        _buildMessageText(lastMessage['text'] as String),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMessageTime(_createdAt, _isMessageSeen),
                  if (!_isMessageSeen) _buildUnreadIndicator()
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildChats() {
      return StreamBuilder<QuerySnapshot<Json>>(
        stream: GetIt.I
            .get<FirestoreService>()
            .messagesStreamByUserUid(userUid: _user!.uid),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Json>> snapshot) {
          if (snapshot.hasData) {
            final _items = snapshot.data!.docs;

            // Removes empty message docs.
            _items.removeWhere((e) => (e.get('latestMessage') as Json).isEmpty);

            if (_items.isEmpty) {
              return _buildNoChats();
            }

            return Consumer<UserControllerImpl>(
              builder: (BuildContext context, UserControllerImpl mongoUser,
                  Widget? child) {
                final MyUser? user = mongoUser.user;

                return ListView.separated(
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String _docID = _items[index].id;
                    final String _user2Uid = ChatUtil.getUser2Uid(
                        docID: _docID, user1Uid: _user!.uid);
                    final _latestMessage =
                        _items[index].get('latestMessage') as Json;

                    return FutureBuilder<MyUser>(
                      future: GetIt.I
                          .get<SpringService>()
                          .getUserByUid(uid: _user2Uid),
                      builder: (BuildContext context,
                          AsyncSnapshot<MyUser> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return Center(
                              child: Text(AppLocalizations.of(context)!
                                  .anErrorOccurred),
                            );
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return buildCircularProgressIndicator();
                          case ConnectionState.done:
                            {
                              if (snapshot.hasData) {
                                final MyUser _user2 = snapshot.data!;

                                return _buildMessage(
                                    _docID, _latestMessage, user!, _user2);
                              }

                              return Center(
                                child: Text(AppLocalizations.of(context)!
                                    .anErrorOccurred),
                              );
                            }
                          default:
                            return buildCircularProgressIndicator();
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 100, right: 16),
                      child: Divider(height: 0),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return buildErrorWidget();
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    PreferredSizeWidget _buildAppBar() {
      return AppBar(
        title: Text(AppLocalizations.of(context)!.chats),
        actions: _user == null
            ? null
            : [
                PopupMenuButton<_ChatPopup>(
                  icon: const Icon(FontAwesomeIcons.ellipsisV, size: 20),
                  onSelected: (_ChatPopup result) {
                    if (result == _ChatPopup.blockedUsers) {
                      Navigator.of(context).pushNamed(BlockedUsers.routeName);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<_ChatPopup>(
                      value: _ChatPopup.blockedUsers,
                      child: Text(AppLocalizations.of(context)!.blockedUsers),
                    ),
                  ],
                ),
              ],
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _user == null ? _buildSignIn() : _buildChats(),
      ),
    );
  }
}
