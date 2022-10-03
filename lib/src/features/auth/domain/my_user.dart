typedef Json = Map<String, dynamic>;

List<MyUser> usersFromJson(List<dynamic> json) =>
    List.from(json.map((e) => MyUser.fromJsonExtendedDTO(e as Json)));

class MyUser {
  MyUser({
    required this.uid,
    this.id,
    this.avatar,
    this.email,
    this.nickname,
    this.blockedUsers,
    this.fcmTokens,
    this.favorites,
    this.createdAt,
  });

  factory MyUser.fromJsonBasicDTO(Json json) => MyUser(
        id: json['id'] as String,
        uid: json['uid'] as String,
        avatar: json['avatar'] as String,
        nickname: json['nickname'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  factory MyUser.fromJsonExtendedDTO(Json json) => MyUser(
        id: json['id'] as String,
        uid: json['uid'] as String,
        avatar: json['avatar'] as String,
        nickname: json['nickname'] as String,
        blockedUsers: _setFromJson(json['blockedUsers'] as List<dynamic>),
        fcmTokens: _fcmTokensFromJson(json['fcmTokens'] as Json),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  factory MyUser.fromJson(Json json) => MyUser(
        id: json['id'] as String,
        uid: json['uid'] as String,
        avatar: json['avatar'] as String,
        email: json['email'] as String,
        nickname: json['nickname'] as String,
        blockedUsers: _setFromJson(json['blockedUsers'] as List<dynamic>),
        fcmTokens: _fcmTokensFromJson(json['fcmTokens'] as Json),
        favorites: _setFromJson(json['favorites'] as List<dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String? id;
  final String uid;
  String? avatar;
  String? email;
  String? nickname;
  Set<String>? blockedUsers;
  Map<String, String>? fcmTokens;
  Set<String>? favorites;
  final DateTime? createdAt;

  Json toJson() => <String, dynamic>{
        'id': id,
        'avatar': avatar,
        'email': email,
        'nickname': nickname,
      };

  @override
  String toString() =>
      'MyUser{id: $id, uid: $uid, avatar: $avatar, email: $email, '
      'nickname: $nickname, blockedUsers: $blockedUsers, '
      'fcmTokens: $fcmTokens, favorites: $favorites, createdAt: $createdAt}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyUser && other.id == id && other.uid == uid;
  }

  @override
  int get hashCode => id.hashCode ^ uid.hashCode;
}

Set<String> _setFromJson(List<dynamic> list) => {}..addAll(List.from(list));

Map<String, String> _fcmTokensFromJson(Json json) {
  final fcmTokens = <String, String>{};
  json.forEach((k, v) => fcmTokens.putIfAbsent(k, () => v as String));
  return fcmTokens;
}
