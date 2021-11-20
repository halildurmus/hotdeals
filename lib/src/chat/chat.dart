import '../models/my_user.dart';

typedef Json = Map<String, dynamic>;

class Chat {
  Chat({
    this.id,
    required this.lastMessage,
    required this.loggedInUserUid,
    required this.user1,
    required this.user2,
  }) {
    lastMessageIsFile = lastMessage['type'] == 'file';
    lastMessageIsImage = lastMessage['type'] == 'image';
    final _sentBy = lastMessage['author']['id'] as String;
    isRead = _sentBy != loggedInUserUid
        ? (lastMessage['status'] as String) == 'seen'
        : true;
    isUser1Blocked = user2.blockedUsers!.contains(user1.uid);
    isUser2Blocked = user1.blockedUsers!.contains(user2.uid);
    createdAt = DateTime.fromMillisecondsSinceEpoch(
      lastMessage['createdAt'] as int,
    );
  }

  late final DateTime createdAt;
  final String? id;
  late final bool isRead;
  late final bool isUser1Blocked;
  late final bool isUser2Blocked;
  late final bool lastMessageIsFile;
  late final bool lastMessageIsImage;
  final String loggedInUserUid;
  final Json lastMessage;
  final MyUser user1;
  final MyUser user2;

  @override
  String toString() {
    return 'Chat(createdAt: $createdAt, id: $id, isRead: $isRead, isUser1Blocked: $isUser1Blocked, isUser2Blocked: $isUser2Blocked, lastMessageIsFile: $lastMessageIsFile, lastMessageIsImage: $lastMessageIsImage, loggedInUserUid: $loggedInUserUid, lastMessage: $lastMessage, user1: $user1, user2: $user2)';
  }
}
