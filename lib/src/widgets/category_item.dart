import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  final Category category;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
          horizontalTitleGap: 0,
          leading: Text(
            category.iconLigature,
            style: TextStyle(
              color: theme.primaryColorLight,
              fontFamily: category.iconFontFamily,
              fontSize: 24,
            ),
          ),
          title: Text(
            category.localizedName(Localizations.localeOf(context)),
            style: textTheme.headline6!.copyWith(
              color: theme.primaryColor,
              fontSize: 18,
            ),
          ),
          trailing: Icon(
            FontAwesomeIcons.chevronRight,
            size: 20,
            color: theme.primaryColorLight,
          ),
        ),
      ),
    );
  }
}
