import 'dart:ui' show Locale;

typedef Json = Map<String, dynamic>;

List<Category> categoriesFromJson(List<dynamic> json) =>
    List.from(json.map((e) => Category.fromJson(e as Json)));

class Category {
  Category({
    required this.names,
    required this.parent,
    required this.category,
    required this.iconLigature,
    required this.iconFontFamily,
    this.id,
  });

  factory Category.fromJson(Json json) => Category(
        id: json['id'] as String,
        names: json['names'] as Json,
        parent: json['parent'] as String,
        category: json['category'] as String,
        iconLigature: json['iconLigature'] as String,
        iconFontFamily: json['iconFontFamily'] as String,
      );

  final String? id;
  final Json names;
  final String parent;
  final String category;
  final String iconLigature;
  final String iconFontFamily;

  Json toJson() => {
        'names': names,
        'parent': parent,
        'category': category,
        'iconLigature': iconLigature,
        'iconFontFamily': iconFontFamily,
      };

  @override
  String toString() => 'Category{id: $id, names: $names, parent: $parent, '
      'category: $category, iconLigature: $iconLigature, '
      'iconFontFamily: $iconFontFamily}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.names == names &&
        other.parent == parent &&
        other.category == category &&
        other.iconLigature == iconLigature &&
        other.iconFontFamily == iconFontFamily;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        names.hashCode ^
        parent.hashCode ^
        category.hashCode ^
        iconLigature.hashCode ^
        iconFontFamily.hashCode;
  }
}

extension LocalizedName on Category {
  /// Returns the category's localized name.
  ///
  /// Set [locale] parameter to `Localizations.localeOf(context)` to get the
  /// app's current locale.
  String localizedName(Locale locale) =>
      names[locale.languageCode] ?? names['en'];
}
