import 'dart:ui' show Locale;

import 'package:get_it/get_it.dart';

import '../services/spring_service.dart';
import 'category.dart';

class Categories {
  List<Category>? _categories;

  List<Category>? get categories => _categories;

  List<Category> get mainCategories =>
      _categories!.where((e) => e.parent == '/').toList();

  List<Category> getSubcategoriesByCategory(Category category) =>
      _categories!.where((e) => e.parent == category.category).toList();

  Future<List<Category>> getCategories() async {
    _categories = await GetIt.I.get<SpringService>().getCategories();
    // Sort categories alphabetically by name.
    _categories!.sort((a, b) => a.names['en'].compareTo(b.names['en']));

    return _categories!;
  }

  /// Returns the localized category name.
  String getCategoryNameFromCategory({
    required String category,
    required Locale locale,
  }) =>
      _categories!
          .singleWhere((e) => e.category == category)
          .localizedName(locale);
}
