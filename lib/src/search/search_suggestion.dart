typedef Json = Map<String, dynamic>;

class SearchSuggestion {
  SearchSuggestion({required this.suggestions});

  factory SearchSuggestion.fromJson(dynamic json) {
    final list = List.from(json);
    final suggestions = list.map((e) => e['title'] as String).toList();
    print(suggestions.length);

    return SearchSuggestion(suggestions: suggestions);
  }

  final List<String> suggestions;

  @override
  String toString() => 'SearchSuggestion(suggestions: $suggestions)';
}
