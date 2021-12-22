typedef Json = Map<String, dynamic>;

class SuggestionResponse {
  SuggestionResponse({required this.suggestions});

  factory SuggestionResponse.fromJson(dynamic json) {
    final list = List.from(json);
    final suggestions = <String>[];
    for (final element in list) {
      suggestions.add(element['_source']['title'] as String);
    }

    return SuggestionResponse(suggestions: suggestions);
  }

  final List<String> suggestions;

  @override
  String toString() => 'SuggestionResponse(suggestions: $suggestions)';
}
