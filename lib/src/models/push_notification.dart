import 'notification_verb.dart';

typedef Json = Map<String, dynamic>;

class PushNotification {
  PushNotification({
    this.id,
    required this.title,
    required this.body,
    required this.actor,
    required this.verb,
    required this.object,
    this.avatar,
    this.message,
    this.uid,
    this.isRead = false,
    this.createdAt,
  }) {
    createdAt ??= DateTime.now();
  }

  /// Creates a [PushNotification] from a [Map].
  factory PushNotification.fromMap(Map<String, Object?> map) =>
      PushNotification(
        id: map['id']! as int,
        title: map['title']! as String,
        body: map['body']! as String,
        actor: map['actor']! as String,
        verb: notificationVerbFromString(map['verb']! as String),
        object: map['object']! as String,
        message: map['message'] as String?,
        uid: map['uid'] as String?,
        isRead: map['is_read']! == 1,
        createdAt: DateTime.parse(map['created_at']! as String),
      );

  final int? id;
  final String title;
  final String body;
  final String actor;
  final NotificationVerb verb;
  final String object;
  final String? avatar;
  final String? message;
  final String? uid;
  bool isRead;
  DateTime? createdAt;

  /// Converts a [PushNotification] into a [Json].
  Json toJson() => <String, dynamic>{
        'title': title,
        'body': body,
        // 'image': null,
        'data': <String, dynamic>{
          'actor': actor,
          'verb': verb.asString,
          'object': object,
          if (avatar != null) 'avatar': avatar,
          if (message != null) 'message': message,
          if (uid != null) 'uid': uid,
        }
      };

  /// Converts a [PushNotification] into a [Map].
  /// The keys must correspond to the names of the columns in the database.
  Json toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'actor': actor,
        'verb': verb.asString,
        'object': object,
        'message': message,
        'uid': uid,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt!.toIso8601String(),
      };

  @override
  String toString() {
    return 'PushNotification{id: $id, title: $title, body: $body, actor: $actor, verb: $verb, object: $object, avatar: $avatar, message: $message, uid: $uid, isRead: $isRead, createdAt: $createdAt}';
  }
}
