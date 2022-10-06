import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../../browse/data/categories_provider.dart';
import '../../browse/data/stores_provider.dart';
import '../../browse/domain/category.dart';
import '../../browse/domain/store.dart';
import '../domain/deal_form_data.dart';

final dealFormControllerProvider =
    StateNotifierProvider.autoDispose<DealFormController, DealFormData>(
        (ref) => DealFormController(ref.read),
        name: 'PostDealControllerProvider');

class DealFormController extends StateNotifier<DealFormData> with NetworkLoggy {
  DealFormController(Reader read)
      : super(DealFormData(
          selectedCategory: read(categoriesProvider).mainCategories.first,
          selectedStore: read(storesProvider).stores.first,
        ));

  void onCategoryChanged(Category? newValue) {
    if (state.selectedCategory == newValue) return;
    state = state.copyWith(selectedCategory: newValue);
  }

  void onStoreChanged(Store? newValue) {
    if (state.selectedStore == newValue) return;
    state = state.copyWith(selectedStore: newValue);
  }
}
