import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<SearchHit> searchResultsFromJson(String str) =>
    List<SearchHit>.from((json.decode(str) as List<dynamic>)
        .map<dynamic>((dynamic x) => SearchHit.fromJson(x as Json)));

class SearchHit {
  SearchHit({
    required this.id,
    required this.content,
  });

  factory SearchHit.fromJson(Json json) => SearchHit(
        id: json['id'] as String,
        content: Content.fromJson(json['content'] as Json),
      );

  final String id;
  final Content content;

  @override
  String toString() {
    return 'SearchResults{id: $id, content: $content}';
  }
}

class Content {
  Content({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Content.fromJson(Json json) => Content(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
      );

  final String id;
  final String title;
  final String description;

  @override
  String toString() {
    return 'Content{id: $id, title: $title, description: $description}';
  }
}
