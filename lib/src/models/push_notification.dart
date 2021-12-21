import 'notification_verb.dart';

typedef Json = Map<String, dynamic>;

class PushNotification {
  PushNotification({
    this.id,
    this.title,
    this.titleLocKey,
    this.titleLocArgs,
    this.body,
    this.bodyLocKey,
    this.bodyLocArgs,
    required this.actor,
    required this.verb,
    required this.object,
    this.tokens = const [],
    required this.avatar,
    required this.message,
    this.image,
    required this.uid,
    this.isRead = false,
    this.createdAt,
  })  : assert(title != null || titleLocKey != null),
        assert(body != null || bodyLocKey != null) {
    createdAt ??= DateTime.now();
  }

  /// Creates a [PushNotification] from a [Map].
  factory PushNotification.fromMap(Map<String, Object?> map) =>
      PushNotification(
        id: map['id']! as int,
        title: map['title'] as String?,
        titleLocKey: map['title_loc_key'] as String?,
        titleLocArgs: (map['title_loc_args'] as String?)?.split(','),
        bodyLocKey: map['body_loc_key'] as String?,
        bodyLocArgs: (map['body_loc_args'] as String?)?.split(','),
        actor: map['actor']! as String,
        verb: NotificationVerb.values.byName(map['verb']! as String),
        object: map['object']! as String,
        message: map['message']! as String,
        image: map['image'] as String?,
        avatar: map['avatar']! as String,
        uid: map['uid']! as String,
        isRead: map['is_read']! == 1,
        createdAt: DateTime.parse(map['created_at']! as String),
      );

  final int? id;
  final String? title;
  final String? titleLocKey;
  final List<String>? titleLocArgs;
  final String? body;
  final String? bodyLocKey;
  final List<String>? bodyLocArgs;
  final String actor;
  final NotificationVerb verb;
  final String object;
  final List<String> tokens;
  final String avatar;
  final String message;
  final String? image;
  final String uid;
  bool isRead;
  DateTime? createdAt;

  /// Converts a [PushNotification] into a [Json].
  Json toJson() => <String, dynamic>{
        if (title != null) 'title': title,
        if (titleLocKey != null) 'titleLocKey': titleLocKey,
        if (titleLocArgs != null) 'titleLocArgs': titleLocArgs,
        if (body != null) 'body': body,
        if (bodyLocKey != null) 'bodyLocKey': bodyLocKey,
        if (bodyLocArgs != null) 'bodyLocArgs': bodyLocArgs,
        if (image != null) 'image': image,
        'data': <String, dynamic>{
          'verb': verb.name,
          'object': object,
          'avatar': avatar,
          'message': message,
          'uid': uid,
        },
        'tokens': tokens,
      };

  /// Converts a [PushNotification] into a [Map].
  /// The keys must correspond to the names of the columns in the database.
  Json toMap() => <String, dynamic>{
        'id': id,
        if (title != null) 'title': title,
        if (titleLocKey != null) 'title_loc_key': titleLocKey,
        if (titleLocArgs != null) 'title_loc_args': titleLocArgs!.join(','),
        if (body != null) 'body': body,
        if (bodyLocKey != null) 'body_loc_key': bodyLocKey,
        if (bodyLocArgs != null) 'body_loc_args': bodyLocArgs!.join(','),
        'actor': actor,
        'verb': verb.name,
        'object': object,
        'message': message,
        if (image != null) 'image': image,
        'avatar': avatar,
        'uid': uid,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt!.toIso8601String(),
      };

  @override
  String toString() {
    return 'PushNotification{id: $id, title: $title, titleLocKey: $titleLocKey, titleLocArgs: $titleLocArgs, body: $body, bodyLocKey: $bodyLocKey, bodyLocArgs: $bodyLocArgs, actor: $actor, verb: $verb, object: $object, tokens: $tokens, avatar: $avatar, message: $message, image: $image, uid: $uid, isRead: $isRead, createdAt: $createdAt}';
  }
}
