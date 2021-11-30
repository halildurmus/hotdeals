import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/firestore_service.dart';
import '../services/spring_service.dart';
import '../utils/chat_util.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/error_indicator.dart';
import 'blocked_users.dart';
import 'chat.dart';
import 'chat_item.dart';
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

  Widget _buildChatItem(Chat chat) {
    return ChatItem(
      chat: chat,
      onTap: () => Navigator.of(context).pushNamed(
        MessageScreen.routeName,
        arguments: MessageArguments(docId: chat.id, user2: chat.user2),
      ),
    );
  }

  Widget _buildListView(
    List<QueryDocumentSnapshot<Json>> items,
    MyUser user1,
  ) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final docID = items[index].id;
        final user2Uid =
            ChatUtil.getUser2Uid(docID: docID, user1Uid: _user!.uid);
        final lastMessage = items[index].get('latestMessage') as Json;

        if (_users.containsKey(user2Uid)) {
          final MyUser user2 = _users[user2Uid]!;
          final chat = Chat(
            id: docID,
            lastMessage: lastMessage,
            loggedInUserUid: _user!.uid,
            user1: user1,
            user2: user2,
          );

          return _buildChatItem(chat);
        }

        return FutureBuilder<MyUser>(
          future: GetIt.I.get<SpringService>().getUserByUid(uid: user2Uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final MyUser user2 = snapshot.data!;
              _users[user2Uid] = user2;
              final chat = Chat(
                id: docID,
                lastMessage: lastMessage,
                loggedInUserUid: _user!.uid,
                user1: user1,
                user2: user2,
              );

              return _buildChatItem(chat);
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
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data!.docs;
          // Removes empty message docs.
          items.removeWhere((e) => (e.get('latestMessage') as Json).isEmpty);
          if (items.isEmpty) {
            return _buildNoChats();
          }

          return _buildConsumer(items);
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
      actions: _user != null ? _buildActions() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _user != null ? _buildStreamBuilder() : _buildSignIn(),
    );
  }
}
