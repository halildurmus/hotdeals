import 'my_user.dart';

typedef Json = Map<String, dynamic>;

class Comment {
  const Comment({
    this.id,
    this.postedBy,
    required this.message,
    this.createdAt,
  });

  factory Comment.fromJson(Json json) => Comment(
        id: json['id'] as String,
        postedBy: MyUser.fromJsonBasicDTO(json['postedBy'] as Json),
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String? id;
  final MyUser? postedBy;
  final String message;
  final DateTime? createdAt;

  Json toJson() => <String, dynamic>{'message': message};

  @override
  String toString() =>
      'Comment{id: $id, postedBy: $postedBy, message: $message, createdAt: $createdAt}';
}
