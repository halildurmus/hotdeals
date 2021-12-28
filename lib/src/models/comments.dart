import 'comment.dart';

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
