import '../../auth/domain/my_user.dart';

typedef Json = Map<String, dynamic>;

List<Comment> commentsFromJson(List<dynamic> json) =>
    List.from(json.map((e) => Comment.fromJson(e as Json)));

class Comments {
  const Comments({required this.count, required this.comments});

  factory Comments.fromJson(Json json) => Comments(
        count: json['count'] as int,
        comments: commentsFromJson(json['comments']),
      );

  final int count;
  final List<Comment> comments;

  @override
  String toString() => 'Comments{count: $count, comments: $comments}';
}

class Comment {
  const Comment({
    required this.message,
    this.id,
    this.dealId,
    this.postedBy,
    this.createdAt,
  });

  factory Comment.fromJson(Json json) => Comment(
        id: json['id'] as String,
        dealId: json['dealId'] as String,
        postedBy: MyUser.fromJsonBasicDTO(json['postedBy'] as Json),
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String? id;
  final String? dealId;
  final MyUser? postedBy;
  final String message;
  final DateTime? createdAt;

  Json toJson() => {'message': message};

  @override
  String toString() =>
      'Comment{id: $id, dealId: $dealId, postedBy: $postedBy, message: $message, createdAt: $createdAt}';
}
