import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/firestore_service.dart';
import '../services/spring_service.dart';
import '../utils/chat_util.dart';
import '../utils/date_time_util.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/error_indicator.dart';
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
  final Map<String, MyUser> _users = {};
  late MyUser? _user;

  @override
  void initState() {
    _user = context.read<UserController>().user;
    super.initState();
  }

  Widget _buildSignIn() {
    return ErrorIndicator(
      icon: Icons.chat,
      title: AppLocalizations.of(context)!.youNeedToSignIn,
      message: AppLocalizations.of(context)!.youNeedToSignInToSee,
    );
  }

  Widget _buildNoChats() {
    return ErrorIndicator(
      icon: Icons.chat,
      title: AppLocalizations.of(context)!.noChats,
      message: AppLocalizations.of(context)!.noActiveConversations,
    );
  }

  Widget _buildCircularProgressIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBlockedText() {
    return Row(
      children: [
        Icon(Icons.error, size: 18, color: Theme.of(context).errorColor),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context)!.youCannotChatWithThisUser,
          style: TextStyle(color: Theme.of(context).errorColor, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildFileText(String fileName) {
    return Row(
      children: [
        Icon(
          Icons.description,
          color: Theme.of(context).primaryColorLight,
          size: 18,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: MediaQuery.of(context).size.width * .55,
          child: Text(
            fileName,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15),
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
          color: Theme.of(context).primaryColorLight,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context)!.image,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildMessageText(String text) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15),
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
      width: MediaQuery.of(context).size.width * .55,
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
        color: isRead ? Colors.grey : Theme.of(context).primaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildUnreadIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget _buildMessage(
      String docId,
      Json lastMessage,
      MyUser user,
      MyUser user2,
    ) {
      final _lastMessageIsFile = lastMessage['type'] == 'file';
      final _lastMessageIsImage = lastMessage['type'] == 'image';
      final _sentBy = lastMessage['author']['id'] as String;
      bool _isMessageSeen;
      if (_sentBy != _user!.uid) {
        _isMessageSeen = (lastMessage['status'] as String) == 'seen';
      } else {
        _isMessageSeen = true;
      }
      final _isUserBlocked = user2.blockedUsers!.contains(user.uid);
      final _isUser2Blocked = user.blockedUsers!.contains(user2.uid);
      final DateTime _createdAt = DateTime.fromMillisecondsSinceEpoch(
        lastMessage['createdAt'] as int,
      );

      // TODO(halildurmus): Extract this as a stateless widget
      return InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          MessageScreen.routeName,
          arguments: MessageArguments(
            docId: docId,
            user2: user2,
          ),
        ),
        child: Container(
          color: _isMessageSeen ? null : theme.primaryColor.withOpacity(.1),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (!_isMessageSeen) _buildUnreadIndicator(),
                  _buildUserAvatar(user2.avatar!),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserNickname(user2.nickname!),
                      const SizedBox(height: 4),
                      if (_isUserBlocked || _isUser2Blocked)
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
              _buildMessageTime(_createdAt, _isMessageSeen),
            ],
          ),
        ),
      );
    }

    Widget _buildListView(
      List<QueryDocumentSnapshot<Json>> items,
      MyUser user,
    ) {
      return ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final String _docID = items[index].id;
          final String _user2Uid =
              ChatUtil.getUser2Uid(docID: _docID, user1Uid: _user!.uid);
          final _latestMessage = items[index].get('latestMessage') as Json;

          if (_users.containsKey(_user2Uid)) {
            final MyUser _user2 = _users[_user2Uid]!;

            return _buildMessage(_docID, _latestMessage, user, _user2);
          }

          return FutureBuilder<MyUser>(
            future: GetIt.I.get<SpringService>().getUserByUid(uid: _user2Uid),
            builder: (context, AsyncSnapshot<MyUser> snapshot) {
              if (snapshot.hasData) {
                final MyUser _user2 = snapshot.data!;
                _users[_user2Uid] = _user2;

                return _buildMessage(_docID, _latestMessage, user, _user2);
              } else if (snapshot.hasError) {
                return ErrorIndicatorUtil.buildNewPageError(
                  context,
                  onTryAgain: () => setState(() {}),
                );
              }

              return _buildCircularProgressIndicator();
            },
          );
        },
        separatorBuilder: (context, index) =>
            const Divider(height: 0, indent: 16, endIndent: 16),
      );
    }

    Widget _buildConsumer(List<QueryDocumentSnapshot<Json>> items) {
      return Consumer<UserController>(
        builder: (context, ctrl, child) {
          final MyUser user = ctrl.user!;

          return _buildListView(items, user);
        },
      );
    }

    Widget _buildStreamBuilder() {
      return StreamBuilder<QuerySnapshot<Json>>(
        stream: GetIt.I
            .get<FirestoreService>()
            .messagesStreamByUserUid(userUid: _user!.uid),
        builder: (context, AsyncSnapshot<QuerySnapshot<Json>> snapshot) {
          if (snapshot.hasData) {
            final _items = snapshot.data!.docs;
            // Removes empty message docs.
            _items.removeWhere((e) => (e.get('latestMessage') as Json).isEmpty);
            if (_items.isEmpty) {
              return _buildNoChats();
            }

            return _buildConsumer(_items);
          } else if (snapshot.hasError) {
            return ErrorIndicatorUtil.buildFirstPageError(
              context,
              onTryAgain: () => setState(() {}),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    List<Widget> _buildActions() {
      return [
        PopupMenuButton<_ChatPopup>(
          icon: const Icon(Icons.more_vert),
          onSelected: (_ChatPopup result) {
            if (result == _ChatPopup.blockedUsers) {
              Navigator.of(context).pushNamed(BlockedUsers.routeName);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<_ChatPopup>(
              value: _ChatPopup.blockedUsers,
              child: Text(AppLocalizations.of(context)!.blockedUsers),
            ),
          ],
        ),
      ];
    }

    PreferredSizeWidget _buildAppBar() {
      return AppBar(
        title: Text(AppLocalizations.of(context)!.chats),
        actions: _user == null ? null : _buildActions(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: _user == null ? _buildSignIn() : _buildStreamBuilder(),
    );
  }
}
