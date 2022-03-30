// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/categories.dart';
import '../models/stores.dart';
import '../search/search_params.dart';

class CustomFilterChip extends StatelessWidget {
  CustomFilterChip.category({
    required this.filters,
    required this.icon,
    required this.label,
    required this.labelPlural,
    required this.onSelected,
    Key? key,
  }) : super(key: key) {
    _filterType = FilterType.category;
  }

  CustomFilterChip.price({
    required this.filters,
    required this.icon,
    required this.label,
    required this.labelPlural,
    required this.onSelected,
    Key? key,
  }) : super(key: key) {
    _filterType = FilterType.price;
  }

  CustomFilterChip.store({
    required this.filters,
    required this.icon,
    required this.label,
    required this.labelPlural,
    required this.onSelected,
    Key? key,
  }) : super(key: key) {
    _filterType = FilterType.store;
  }

  late final FilterType _filterType;
  final IconData icon;
  final List<Object> filters;
  final String label;
  final String labelPlural;
  final void Function(bool) onSelected;

  String getCategoryName(BuildContext context, String category) =>
      GetIt.I.get<Categories>().getCategoryNameFromCategory(
            category: category,
            locale: Localizations.localeOf(context),
          );

  String getStoreName(BuildContext context, String storeId) =>
      GetIt.I.get<Stores>().getStoreByStoreId(storeId).name;

  String getFilterName(BuildContext context, Object filterKey) {
    switch (_filterType) {
      case FilterType.category:
        return getCategoryName(context, filterKey as String);
      case FilterType.price:
        return (filterKey as PriceRange).formattedString;
      case FilterType.store:
        return getStoreName(context, filterKey as String);
      default:
        throw Exception('Invalid filterType: $_filterType');
    }
  }

  String getLabel(BuildContext context) {
    if (filters.length >= 2) {
      return labelPlural;
    } else if (filters.length == 1) {
      return getFilterName(context, filters.first);
    } else {
      return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final isSelected = filters.isNotEmpty;

    return FilterChip(
      onSelected: onSelected,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filters.length >= 2)
            CircleAvatar(
              backgroundColor: isDarkMode
                  ? Colors.white
                  : theme.colorScheme.secondaryVariant,
              radius: 9,
              child: Text(
                filters.length.toString(),
                style: TextStyle(
                  color:
                      isDarkMode ? theme.colorScheme.secondary : Colors.white,
                  fontSize: 12.5,
                ),
              ),
            ),
          Row(
            children: [
              if (filters.length == 1)
                Icon(
                  icon,
                  color: isDarkMode ? null : theme.colorScheme.secondaryVariant,
                  size: 18,
                ),
              const SizedBox(width: 5),
              Text(
                getLabel(context),
                style: textTheme.subtitle2!.copyWith(
                  color: isDarkMode
                      ? null
                      : filters.isNotEmpty
                          ? theme.colorScheme.secondaryVariant
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
                    ? theme.colorScheme.secondaryVariant
                    : null,
            size: 20,
          ),
        ],
      ),
      selected: filters.isNotEmpty,
      selectedColor: isDarkMode
          ? theme.colorScheme.secondary
          : theme.colorScheme.secondaryVariant.withOpacity(.25),
      showCheckmark: false,
      side: isDarkMode
          ? null
          : BorderSide(
              color: isSelected
                  ? theme.colorScheme.secondaryVariant.withOpacity(.25)
                  : theme.chipTheme.backgroundColor!.withOpacity(.07),
              width: .25,
            ),
    );
  }
}
