import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common_widgets/error_indicator.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../helpers/context_extensions.dart';
import '../../auth/presentation/user_controller.dart';
import '../data/firestore_service.dart';
import '../domain/chat.dart';
import '../domain/chat_util.dart';
import 'widgets/chat_item.dart';

enum _ChatPopup { blockedUsers }

typedef Json = Map<String, dynamic>;

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  static const String routeName = '/chats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final chatMessages = ref.watch(chatMessagesStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.chats),
        actions: [
          PopupMenuButton<_ChatPopup>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem<_ChatPopup>(
                value: _ChatPopup.blockedUsers,
                child: Text(context.l.blockedUsers),
              ),
            ],
            onSelected: (result) {
              switch (result) {
                case _ChatPopup.blockedUsers:
                  context.goNamed('blocked-users');
                  break;
              }
            },
          ),
        ],
      ),
      body: chatMessages.when(
        data: (snapshot) {
          final items = snapshot.docs
            ..removeWhere((e) => (e.get('latestMessage') as Json).isEmpty);
          if (items.isEmpty) {
            return ErrorIndicator(
              icon: Icons.chat,
              title: context.l.noChats,
              message: context.l.noActiveConversations,
            );
          }

          return ListView.separated(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final docID = items[index].id;
              final lastMessage = items[index].get('latestMessage') as Json;
              final user2Uid =
                  ChatUtil.getUser2Uid(docID: docID, user1Uid: user.uid);
              final user2 = ref.watch(userByUidFutureProvider(user2Uid));
              return user2.when(
                data: (user2) {
                  final chat = Chat(
                    id: docID,
                    lastMessage: lastMessage,
                    loggedInUserUid: user.uid,
                    user1: user,
                    user2: user2,
                  );

                  return ChatItem(
                    chat: chat,
                    onTap: () => context.go('/chats/${chat.id}', extra: user2),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SomethingWentWrongError(
                  onPressed: () =>
                      ref.refresh(userByUidFutureProvider(user2Uid)),
                ),
              );
            },
            separatorBuilder: (_, __) =>
                const Divider(indent: 16, endIndent: 16),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => NoConnectionError(
          onPressed: () => ref.refresh(chatMessagesStreamProvider(user.uid)),
        ),
      ),
    );
  }
}
