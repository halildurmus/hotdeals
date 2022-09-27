import 'package:flutter/material.dart';

import '../helpers/context_extensions.dart';

class ExpiredFilterChip extends StatelessWidget {
  const ExpiredFilterChip({
    required this.hideExpired,
    required this.label,
    required this.onSelected,
    super.key,
  });

  final bool hideExpired;
  final String label;
  final void Function(bool) onSelected;

  String getFilterName(BuildContext context) {
    final filter = hideExpired ? context.l.hide : context.l.show;
    return '$label: $filter';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final isSelected = hideExpired;

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
