import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../helpers/context_extensions.dart';
import '../../data/categories_provider.dart';
import '../../domain/category.dart';

class FilterChips extends ConsumerStatefulWidget {
  const FilterChips({
    required this.category,
    required this.onFilterChange,
    super.key,
  });

  final Category category;
  final void Function(Category newCategory) onFilterChange;

  @override
  ConsumerState<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends ConsumerState<FilterChips> {
  int selectedFilter = -1;

  @override
  Widget build(BuildContext context) {
    final subcategories =
        ref.watch(categoriesProvider).subcategoriesByCategory(widget.category);
    if (subcategories.isEmpty) return const SizedBox();

    return Container(
      height: 65,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: context.t.shadowColor.withOpacity(.2),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        color: context.t.backgroundColor,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = subcategories.elementAt(index);

          return FilterChip(
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: selectedFilter == index
                  ? Colors.white
                  : context.t.primaryColorLight,
              fontWeight: FontWeight.bold,
            ),
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            side: BorderSide(
              color: selectedFilter == index
                  ? Colors.transparent
                  : context.t.primaryColor,
            ),
            pressElevation: 0,
            elevation: selectedFilter == index ? 4 : 0,
            backgroundColor: context.t.backgroundColor,
            label: Text(
              subcategory.localizedName(Localizations.localeOf(context)),
            ),
            selectedColor: context.t.primaryColor,
            selected: selectedFilter == index,
            onSelected: (selected) {
              if (selected) {
                selectedFilter = index;
                widget.onFilterChange(subcategory);
              } else {
                selectedFilter = -1;
                widget.onFilterChange(widget.category);
              }
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }
}
