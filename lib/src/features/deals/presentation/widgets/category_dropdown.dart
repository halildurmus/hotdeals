import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../helpers/context_extensions.dart';
import '../../../browse/data/categories_provider.dart';
import '../../../browse/domain/category.dart';
import '../deal_form_controller.dart';

class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({this.selectedCategoryPath, super.key});

  final String? selectedCategoryPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).mainCategories;
    final controller = ref.watch(dealFormControllerProvider);
    final selectedCategory = selectedCategoryPath != null
        ? categories.singleWhere((c) => c.category == selectedCategoryPath)
        : controller.selectedCategory;

    return DropdownButtonFormField<Category>(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: context.l.category,
      ),
      value: selectedCategory,
      onChanged:
          ref.read(dealFormControllerProvider.notifier).onCategoryChanged,
      selectedItemBuilder: (context) => categories
          .map<Widget>((item) =>
              Text(item.localizedName(Localizations.localeOf(context))))
          .toList(),
      items: categories
          .map(
            (value) => DropdownMenuItem<Category>(
              value: value,
              child: ListTile(
                title:
                    Text(value.localizedName(Localizations.localeOf(context))),
                trailing: (controller.selectedCategory == value)
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
