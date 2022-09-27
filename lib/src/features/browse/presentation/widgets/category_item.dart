import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/context_extensions.dart';
import '../../domain/category.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        onTap: () => context.go('/deals/byCategory', extra: category),
        horizontalTitleGap: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        leading: Text(
          category.iconLigature,
          style: TextStyle(
            color: context.isDarkMode
                ? context.t.primaryColorLight
                : context.t.primaryColor,
            fontFamily: category.iconFontFamily,
            fontSize: 24,
          ),
        ),
        title: Text(
          category.localizedName(Localizations.localeOf(context)),
          style: context.textTheme.headline6!.copyWith(fontSize: 18),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: context.isDarkMode ? null : context.t.primaryColor,
          size: 30,
        ),
      ),
    );
  }
}
