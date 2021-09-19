import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<Category> categoryFromJson(String str) => List<Category>.from(
    (json.decode(str)['_embedded']['categories'] as List<dynamic>)
        .map<dynamic>((dynamic e) => Category.fromJson(e as Json)));

class Category {
  Category({
    this.id,
    required this.name,
    required this.parent,
    required this.category,
    required this.iconLigature,
    required this.iconFontFamily,
  });

  factory Category.fromJson(Json json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        parent: json['parent'] as String,
        category: json['category'] as String,
        iconLigature: json['iconLigature'] as String,
        iconFontFamily: json['iconFontFamily'] as String,
      );

  final String? id;
  final String name;
  final String parent;
  final String category;
  final String iconLigature;
  final String iconFontFamily;

  Json toJson() => <String, dynamic>{
        'name': name,
        'parent': parent,
        'category': category,
        'iconLigature': iconLigature,
        'iconFontFamily': iconFontFamily,
      };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, parent: $parent, category: $category, '
        'iconLigature: $iconLigature, iconFontFamily: $iconFontFamily}';
  }
}
