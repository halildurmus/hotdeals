import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<MyUser> blockedUsersFromJson(String str) =>
    List<MyUser>.from((json.decode(str) as List<dynamic>)
        .map<dynamic>((dynamic e) => MyUser.fromJson(e as Json)));

List<MyUser> userFromJson(String str) =>
    List<MyUser>.from((json.decode(str)['_embedded']['users'] as List<dynamic>)
        .map<dynamic>((dynamic e) => MyUser.fromJson(e as Json)));

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
    this.updatedAt,
  });

  factory MyUser.fromJsonDTO(Json json) => MyUser(
        id: json['id'] as String,
        uid: json['uid'] as String,
        avatar: json['avatar'] as String,
        nickname: json['nickname'] as String,
      );

  factory MyUser.fromJson(Json json) => MyUser(
        id: json['id'] as String,
        uid: json['uid'] as String,
        avatar: json['avatar'] as String,
        email: json['email'] as String,
        nickname: json['nickname'] as String,
        blockedUsers: _blockedUsersFromJson(json['blockedUsers'] as Json),
        fcmTokens: List<String>.from(json['fcmTokens'] as List<dynamic>),
        favorites: _favoritesFromJson(json['favorites'] as Json),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String uid;
  String? avatar;
  String? email;
  String? nickname;
  Map<String, bool>? blockedUsers;
  List<String>? fcmTokens;
  Map<String, bool>? favorites;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() => <String, dynamic>{
        'id': id,
        'avatar': avatar,
        'email': email,
        'nickname': nickname,
      };

  @override
  String toString() {
    return 'MyUser{id: $id, uid: $uid, avatar: $avatar, email: $email, '
        'nickname: $nickname, blockedUsers: $blockedUsers, '
        'fcmTokens: $fcmTokens, favorites: $favorites}';
  }
}

Map<String, bool> _blockedUsersFromJson(Json json) {
  final blockedUsers = <String, bool>{};

  json.forEach((String k, dynamic v) {
    blockedUsers.putIfAbsent(k, () => v as bool);
  });

  return blockedUsers;
}

Map<String, bool> _favoritesFromJson(Json json) {
  final favorites = <String, bool>{};

  json.forEach((String k, dynamic v) {
    favorites.putIfAbsent(k, () => v as bool);
  });

  return favorites;
}
