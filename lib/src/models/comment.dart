import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<Comment> commentFromJson(String str) => List<Comment>.from(
    (json.decode(str)['_embedded']['comments'] as List<dynamic>)
        .map<dynamic>((dynamic e) => Comment.fromJson(e as Json)));

class Comment {
  const Comment({
    this.id,
    required this.dealId,
    required this.postedBy,
    required this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Json json) => Comment(
        id: json['id'] as String,
        dealId: json['dealId'] as String,
        postedBy: json['postedBy'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String dealId;
  final String postedBy;
  final String message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      'dealId': dealId,
      'postedBy': postedBy,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'Comment{id: $id, dealId: $dealId, postedBy: $postedBy, message: $message, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
