import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<SearchHit> searchResultsFromJson(String str) =>
    List<SearchHit>.from((json.decode(str) as List<dynamic>)
        .map<dynamic>((dynamic x) => SearchHit.fromJson(x as Json)));

class SearchHit {
  SearchHit({
    required this.id,
    required this.content,
    required this.highlightFields,
  });

  factory SearchHit.fromJson(Json json) => SearchHit(
        id: json['id'] as String,
        content: Content.fromJson(json['content'] as Json),
        highlightFields:
            HighlightFields.fromJson(json['highlightFields'] as Json),
      );

  final String id;
  final Content content;
  final HighlightFields highlightFields;

  @override
  String toString() {
    return 'SearchResults{id: $id, content: $content, highlightFields: $highlightFields}';
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

class HighlightFields {
  HighlightFields({this.title});

  factory HighlightFields.fromJson(Json json) {
    if (json.isEmpty) {
      return HighlightFields();
    }

    return HighlightFields(
        title: List<String>.from(
            (json['title'] as List<dynamic>).map<dynamic>((dynamic x) => x)));
  }

  final List<String>? title;

  @override
  String toString() {
    return 'HighlightFields{title: $title}';
  }
}
