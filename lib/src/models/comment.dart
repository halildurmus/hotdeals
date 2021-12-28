import 'my_user.dart';

typedef Json = Map<String, dynamic>;

class Comment {
  const Comment({
    this.id,
    this.postedBy,
    this.poster,
    required this.message,
    this.createdAt,
  });

  factory Comment.fromJson(Json json) => Comment(
        id: json['id'] as String,
        postedBy:
            (json['postedBy'] is String) ? json['postedBy'] as String : null,
        poster: (json['postedBy'] is Json)
            ? MyUser.fromJsonDTO(json['postedBy'] as Json)
            : null,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String? id;
  final String? postedBy;
  final MyUser? poster;
  final String message;
  final DateTime? createdAt;

  Json toJson() => <String, dynamic>{'message': message};

  @override
  String toString() =>
      'Comment{id: $id, postedBy: $postedBy, poster: $poster, message: $message, createdAt: $createdAt}';
}
