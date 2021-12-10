typedef Json = Map<String, dynamic>;

class SuggestionResponse {
  SuggestionResponse({required this.suggestions});

  final List<String> suggestions;

  factory SuggestionResponse.fromJson(dynamic json) {
    final list = List.from(json);
    final suggestions = <String>[];
    for (var element in list) {
      suggestions.add(element['_source']['title'] as String);
    }

    return SuggestionResponse(suggestions: suggestions);
  }

  @override
  String toString() => 'SuggestionResponse(suggestions: $suggestions)';
}
