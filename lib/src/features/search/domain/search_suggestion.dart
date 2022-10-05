typedef Json = Map<String, dynamic>;

class SearchSuggestion {
  SearchSuggestion({required this.suggestions});

  factory SearchSuggestion.fromJson(List<dynamic> json) {
    final suggestions = json.map((e) => e['title'] as String).toList();
    return SearchSuggestion(suggestions: suggestions);
  }

  final List<String> suggestions;

  @override
  String toString() => 'SearchSuggestion(suggestions: $suggestions)';
}
