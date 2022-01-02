typedef Json = Map<String, dynamic>;

List<MyUser> usersFromJson(List<dynamic> jsonArray) =>
    List<MyUser>.from(jsonArray
        .map<dynamic>((dynamic e) => MyUser.fromJsonExtendedDTO(e as Json)));

class MyUser {
  MyUser({
    this.id,
    required this.uid,
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
}

Set<String> _setFromJson(List<dynamic> list) =>
    <String>{}..addAll(List.from(list));

Map<String, String> _fcmTokensFromJson(Json json) {
  final fcmTokens = <String, String>{};
  json.forEach((k, dynamic v) {
    fcmTokens.putIfAbsent(k, () => v as String);
  });

  return fcmTokens;
}
