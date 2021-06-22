import 'package:get_it/get_it.dart';

import '../services/spring_service.dart';
import 'category.dart';

class Categories {
  List<Category>? _categories;
  List<Category>? get categories => _categories;
  List<Category>? get mainCategories =>
      _categories!.where((Category e) => e.parent == '/').toList();

  Future<List<Category>> getCategories() async {
    _categories ??= await GetIt.I.get<SpringService>().getCategories();
    // Sort categories alphabetically by name.
    _categories!.sort((Category a, Category b) => a.name.compareTo(b.name));

    return _categories!;
  }

  List<Category> getSubcategories({required Category category}) {
    return _categories!
        .where((Category e) => e.parent == category.category)
        .toList();
  }

  String getCategoryName({required String category}) {
    return _categories!
        .singleWhere((Category e) => e.category == category)
        .name;
  }
}
