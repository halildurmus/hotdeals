import 'package:flutter/material.dart';

import '../features/search/domain/search_params.dart';
import '../helpers/context_extensions.dart';

class SortFilterChip extends StatelessWidget {
  const SortFilterChip({
    required this.label,
    required this.onSelected,
    required this.order,
    required this.sortBy,
    super.key,
  });

  final String label;
  final void Function(bool) onSelected;
  final Order? order;
  final DealSortBy? sortBy;

  String getFilterName(BuildContext context) {
    final filters = <String, dynamic>{
      'relevant': context.l.relevant,
      DealSortBy.createdAt.name: {
        Order.asc.name: context.l.newest,
        Order.desc.name: context.l.oldest
      },
      DealSortBy.price.name: {
        Order.asc.name: context.l.priceLowToHigh,
        Order.desc.name: context.l.priceHighToLow
      }
    };
    final String filter = sortBy == null
        ? filters['relevant']!
        : filters[sortBy!.name]![order!.name]!;

    return '$label: $filter';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isSelected = sortBy != null;

    return FilterChip(
      onSelected: onSelected,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                getFilterName(context),
                style: context.textTheme.subtitle2!.copyWith(
                  color: isDarkMode
                      ? null
                      : isSelected
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
                : isSelected
                    ? context.colorScheme.secondaryContainer
                    : null,
            size: 20,
          ),
        ],
      ),
      selected: isSelected,
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
