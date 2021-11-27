import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../models/my_user.dart';

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
    final _sentBy = lastMessage['author']['id'] as String;
    lastMessageIsRead = _sentBy != loggedInUserUid
        ? lastMessage['status'] as String == 'seen'
        : true;
    user1IsBlocked = user2.blockedUsers!.containsKey(user1.id!);
    user2IsBlocked = user1.blockedUsers!.containsKey(user2.id!);
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
  String toString() {
    return 'Chat(createdAt: $createdAt, id: $id, lastMessage: $lastMessage, lastMessageIsRead: $lastMessageIsRead, lastMessageType: $lastMessageType, loggedInUserUid: $loggedInUserUid, user1: $user1, user1IsBlocked: $user1IsBlocked, user2: $user2, user2IsBlocked: $user2IsBlocked)';
  }
}
