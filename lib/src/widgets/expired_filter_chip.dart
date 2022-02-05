// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../utils/localization_util.dart';

class ExpiredFilterChip extends StatelessWidget {
  const ExpiredFilterChip({
    required this.hideExpired,
    required this.label,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  final bool hideExpired;
  final String label;
  final void Function(bool) onSelected;

  String getFilterName(BuildContext context) {
    final filters = <String>[l(context).hide, l(context).show];
    final filter = hideExpired ? filters[0] : filters[1];

    return '$label: $filter';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
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
                  : theme.chipTheme.backgroundColor!.withOpacity(.07),
              width: .25,
            ),
    );
  }
}
