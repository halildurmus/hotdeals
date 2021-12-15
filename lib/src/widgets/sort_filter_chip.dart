import 'package:flutter/material.dart';

import '../search/search_params.dart';
import '../utils/localization_util.dart';

class SortFilterChip extends StatelessWidget {
  const SortFilterChip({
    Key? key,
    required this.label,
    required this.onSelected,
    required this.order,
    required this.sortBy,
  }) : super(key: key);

  final String label;
  final void Function(bool) onSelected;
  final Order? order;
  final DealSortBy? sortBy;

  String getFilterName(BuildContext context) {
    final filters = <String, dynamic>{
      'relevant': l(context).relevant,
      DealSortBy.createdAt.name: {
        Order.asc.name: l(context).newest,
        Order.desc.name: l(context).oldest
      },
      DealSortBy.price.name: {
        Order.asc.name: l(context).priceLowToHigh,
        Order.desc.name: l(context).priceHighToLow
      }
    };
    final String filter = sortBy == null
        ? filters['relevant']!
        : filters[sortBy!.name]![order!.name]!;

    return '$label: $filter';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final isSelected = sortBy != null;

    return FilterChip(
      onSelected: (value) => onSelected(value),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                getFilterName(context),
                style: textTheme.subtitle2!.copyWith(
                  color: isDarkMode
                      ? null
                      : isSelected
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
                : isSelected
                    ? theme.colorScheme.secondaryVariant
                    : null,
            size: 20,
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: isDarkMode
          ? theme.colorScheme.secondary
          : theme.colorScheme.secondaryVariant.withOpacity(.25),
      showCheckmark: false,
      side: isDarkMode
          ? null
          : BorderSide(
              color: isSelected
                  ? theme.colorScheme.secondaryVariant.withOpacity(.25)
                  : theme.chipTheme.backgroundColor.withOpacity(.07),
              width: .25,
            ),
    );
  }
}
