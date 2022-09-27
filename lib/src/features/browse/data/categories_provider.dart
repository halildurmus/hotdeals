import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/category.dart';

final categoriesProvider = Provider<CategoriesController>(
    (ref) => CategoriesController(),
    name: 'CategoriesProvider');

class CategoriesController {
  var _categories = <Category>[];

  List<Category> get categories => _categories;

  set categories(List<Category> categories) =>
      // Sort categories alphabetically by name
      _categories = categories
        ..sort((a, b) => a.names['en'].compareTo(b.names['en']));

  List<Category> get mainCategories =>
      _categories.where((c) => c.parent == '/').toList();

  List<Category> subcategoriesByCategory(Category category) =>
      _categories.where((c) => c.parent == category.category).toList();

  /// Returns the localized category name.
  String categoryNameFromCategory({
    required String category,
    required Locale locale,
  }) =>
      _categories
          .singleWhere((c) => c.category == category)
          .localizedName(locale);
}
