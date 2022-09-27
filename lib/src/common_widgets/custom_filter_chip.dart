import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/browse/data/categories_provider.dart';
import '../features/browse/data/stores_provider.dart';
import '../features/search/domain/search_params.dart';
import '../helpers/context_extensions.dart';

class CustomFilterChip extends ConsumerWidget {
  const CustomFilterChip.category({
    required this.filters,
    required this.icon,
    required this.label,
    required this.labelPlural,
    required this.onSelected,
    super.key,
  }) : _filterType = FilterType.category;

  const CustomFilterChip.price({
    required this.filters,
    required this.icon,
    required this.label,
    required this.labelPlural,
    required this.onSelected,
    super.key,
  }) : _filterType = FilterType.price;

  const CustomFilterChip.store({
    required this.filters,
    required this.icon,
    required this.label,
    required this.labelPlural,
    required this.onSelected,
    super.key,
  }) : _filterType = FilterType.store;

  final FilterType _filterType;
  final IconData icon;
  final List<Object> filters;
  final String label;
  final String labelPlural;
  final void Function(bool) onSelected;

  String getLabel(
    BuildContext context,
    CategoriesController categoriesController,
    StoresController storesController,
  ) {
    if (filters.isEmpty) return label;
    if (filters.length > 1) return labelPlural;

    final filterKey = filters.first;
    switch (_filterType) {
      case FilterType.category:
        return categoriesController.categoryNameFromCategory(
          category: filterKey as String,
          locale: Localizations.localeOf(context),
        );
      case FilterType.price:
        return (filterKey as PriceRange).formattedString;
      case FilterType.store:
        return storesController.storeByStoreId(filterKey as String).name;
      default:
        throw Exception('Invalid filterType: $_filterType');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = context.isDarkMode;
    final isSelected = filters.isNotEmpty;
    final categoriesController = ref.watch(categoriesProvider);
    final storesController = ref.watch(storesProvider);

    return FilterChip(
      onSelected: onSelected,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filters.length > 1)
            CircleAvatar(
              backgroundColor: isDarkMode
                  ? Colors.white
                  : context.colorScheme.secondaryContainer,
              radius: 9,
              child: Text(
                filters.length.toString(),
                style: TextStyle(
                  color:
                      isDarkMode ? context.colorScheme.secondary : Colors.white,
                  fontSize: 12.5,
                ),
              ),
            ),
          Row(
            children: [
              if (filters.length == 1)
                Icon(
                  icon,
                  color: isDarkMode
                      ? null
                      : context.colorScheme.secondaryContainer,
                  size: 18,
                ),
              const SizedBox(width: 5),
              Text(
                getLabel(context, categoriesController, storesController),
                style: context.textTheme.subtitle2!.copyWith(
                  color: isDarkMode
                      ? null
                      : filters.isNotEmpty
                          ? context.colorScheme.secondaryContainer
                          : null,
                  fontSize: 15,
                  fontWeight: isDarkMode ? null : FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.keyboard_arrow_down,
            color: isDarkMode
                ? null
                : filters.isNotEmpty
                    ? context.colorScheme.secondaryContainer
                    : null,
            size: 20,
          ),
        ],
      ),
      selected: filters.isNotEmpty,
      selectedColor: isDarkMode
          ? context.colorScheme.secondary
          : context.colorScheme.secondaryContainer.withOpacity(.25),
      showCheckmark: false,
      side: isDarkMode
          ? null
          : BorderSide(
              color: isSelected
                  ? context.colorScheme.secondaryContainer.withOpacity(.25)
                  : context.t.chipTheme.backgroundColor!.withOpacity(.07),
              width: .25,
            ),
    );
  }
}
