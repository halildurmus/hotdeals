import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../auth/domain/my_user.dart';

class Chat {
  Chat({
    required this.id,
    required this.lastMessage,
    required this.loggedInUserUid,
    required this.user1,
    required this.user2,
  }) {
    switch (lastMessage['type']) {
      case 'file':
        lastMessageType = types.MessageType.file;
        break;
      case 'image':
        lastMessageType = types.MessageType.image;
        break;
      case 'text':
        lastMessageType = types.MessageType.text;
        break;
      default:
        lastMessageType = types.MessageType.custom;
        break;
    }
    final sentBy = lastMessage['author']['id'] as String;
    lastMessageIsRead = sentBy == loggedInUserUid ||
        (sentBy != loggedInUserUid &&
            lastMessage['status'] as String == 'seen');
    user1IsBlocked = user2.blockedUsers!.contains(user1.id!);
    user2IsBlocked = user1.blockedUsers!.contains(user2.id!);
    createdAt = DateTime.fromMillisecondsSinceEpoch(
      lastMessage['createdAt'] as int,
    );
  }

  late final DateTime createdAt;
  final String id;
  final Json lastMessage;
  late final bool lastMessageIsRead;
  late final types.MessageType lastMessageType;
  final String loggedInUserUid;
  final MyUser user1;
  late final bool user1IsBlocked;
  final MyUser user2;
  late final bool user2IsBlocked;

  @override
  String toString() =>
      'Chat(createdAt: $createdAt, id: $id, lastMessage: $lastMessage, lastMessageIsRead: $lastMessageIsRead, lastMessageType: $lastMessageType, loggedInUserUid: $loggedInUserUid, user1: $user1, user1IsBlocked: $user1IsBlocked, user2: $user2, user2IsBlocked: $user2IsBlocked)';
}
