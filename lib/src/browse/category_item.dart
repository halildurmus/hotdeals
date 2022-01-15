import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    required this.category,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: ListTile(
          horizontalTitleGap: 0,
          leading: Text(
            category.iconLigature,
            style: TextStyle(
              color: isDarkMode ? theme.primaryColorLight : theme.primaryColor,
              fontFamily: category.iconFontFamily,
              fontSize: 24,
            ),
          ),
          title: Text(
            category.localizedName(Localizations.localeOf(context)),
            style: textTheme.headline6!.copyWith(fontSize: 18),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDarkMode ? null : theme.primaryColor,
            size: 30,
          ),
        ),
      ),
    );
  }
}
