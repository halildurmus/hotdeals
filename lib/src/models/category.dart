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
    required this.icon,
  });

  factory Category.fromJson(Json json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        parent: json['parent'] as String,
        category: json['category'] as String,
        icon: CategoryIcon.fromJson(json['icon'] as Json),
      );

  final String? id;
  final String name;
  final String parent;
  final String category;
  final CategoryIcon icon;

  Json toJson() => <String, dynamic>{
        'name': name,
        'parent': parent,
        'category': category,
        'icon': icon.toJson(),
      };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, parent: $parent, category: $category, icon: $icon}';
  }
}

class CategoryIcon {
  CategoryIcon({
    required this.ligature,
    required this.fontFamily,
  });

  factory CategoryIcon.fromJson(Json json) => CategoryIcon(
        ligature: json['ligature'] as String,
        fontFamily: json['fontFamily'] as String,
      );

  final String ligature;
  final String fontFamily;

  Json toJson() => <String, dynamic>{
        'ligature': ligature,
        'fontFamily': fontFamily,
      };

  @override
  String toString() {
    return 'CategoryIcon{ligature: $ligature, fontFamily: $fontFamily}';
  }
}
