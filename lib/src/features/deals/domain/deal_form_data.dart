import 'package:flutter/widgets.dart';

import '../../browse/domain/category.dart';
import '../../browse/domain/store.dart';

@immutable
class DealFormData {
  const DealFormData({
    required this.selectedCategory,
    required this.selectedStore,
  });

  final Category selectedCategory;
  final Store selectedStore;

  DealFormData copyWith({
    Category? selectedCategory,
    Store? selectedStore,
  }) =>
      DealFormData(
        selectedCategory: selectedCategory ?? this.selectedCategory,
        selectedStore: selectedStore ?? this.selectedStore,
      );
}
