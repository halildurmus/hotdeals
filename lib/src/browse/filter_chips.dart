import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/categories.dart';
import '../models/category.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({
    Key? key,
    required this.category,
    required this.onFilterChange,
  }) : super(key: key);

  final Category category;
  final void Function(Category newCategory) onFilterChange;

  @override
  _FilterChipsState createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  late List<Category> subcategories;
  int selectedFilter = -1;

  @override
  void initState() {
    subcategories =
        GetIt.I.get<Categories>().getSubcategoriesByCategory(widget.category);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (subcategories.isEmpty) {
      return const SizedBox();
    }

    return Container(
      height: 65,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(.2),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        color: theme.backgroundColor,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: subcategories.length,
        itemBuilder: (BuildContext context, int index) {
          final Category subcategory = subcategories.elementAt(index);

          return FilterChip(
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: selectedFilter == index
                  ? Colors.white
                  : theme.primaryColorLight,
              fontWeight: FontWeight.bold,
            ),
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            side: BorderSide(
              color: selectedFilter == index
                  ? Colors.transparent
                  : theme.primaryColor,
            ),
            pressElevation: 0,
            elevation: selectedFilter == index ? 4 : 0,
            backgroundColor: theme.backgroundColor,
            label: Text(
              subcategory.localizedName(Localizations.localeOf(context)),
            ),
            selectedColor: theme.primaryColor,
            selected: selectedFilter == index,
            onSelected: (bool selected) {
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
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
      ),
    );
  }
}
