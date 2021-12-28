import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../deal/deal_details.dart';
import '../deal/deal_status.dart';
import '../models/categories.dart';
import '../models/comments.dart';
import '../models/deal.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';
import '../utils/navigation_util.dart';
import 'grayscale_filtered.dart';

class DealItem extends StatefulWidget {
  const DealItem({
    Key? key,
    required this.deal,
    required this.index,
    required this.isFavorited,
    required this.onEditButtonPressed,
    required this.onFavoriteButtonPressed,
    required this.onRemoveButtonPressed,
    required this.pagingController,
    required this.showControlButtons,
  }) : super(key: key);

  final Deal deal;
  final int index;
  final bool isFavorited;
  final VoidCallback onEditButtonPressed;
  final VoidCallback onFavoriteButtonPressed;
  final VoidCallback onRemoveButtonPressed;
  final PagingController pagingController;
  final bool showControlButtons;

  @override
  _DealItemState createState() => _DealItemState();
}

class _DealItemState extends State<DealItem> {
  int _commentsCount = 0;
  int _dealScore = 0;
  int _viewsCount = 0;
  late final Categories _categories;

  @override
  void initState() {
    _categories = GetIt.I.get<Categories>();
    _fetchDealDetails();
    super.initState();
  }

  void _fetchDealDetails() {
    Future.wait([
      GetIt.I.get<SpringService>().getDeal(dealId: widget.deal.id!),
      GetIt.I.get<SpringService>().getComments(dealId: widget.deal.id!),
    ]).then((values) {
      final deal = values[0] as Deal?;
      final commentCount = (values[1] as Comments?)?.count;
      if (commentCount != null && deal != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _dealScore = deal.dealScore!;
              _commentsCount = commentCount;
              _viewsCount = deal.views!;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;
    final deal = widget.deal;

    Widget buildDealCoverPhoto() => Container(
          width: 60,
          height: 60,
          padding: theme.brightness == Brightness.dark
              ? const EdgeInsets.all(2)
              : null,
          margin: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? Colors.white : null,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Image.network(deal.coverPhoto, fit: BoxFit.cover),
        );

    Widget buildDealTitle() => SizedBox(
          width: deviceWidth * .65,
          child: Text(
            deal.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: textTheme.headline6!.copyWith(fontSize: 18),
          ),
        );

    Widget buildControlButtons() => Positioned(
          right: 48,
          top: 88,
          child: Row(
            children: [
              FloatingActionButton(
                onPressed: widget.onEditButtonPressed,
                backgroundColor: theme.backgroundColor,
                heroTag: null,
                mini: true,
                child: Icon(
                  Icons.edit,
                  color: isDarkMode ? null : theme.primaryColor,
                  size: 18,
                ),
              ),
              FloatingActionButton(
                onPressed: widget.onRemoveButtonPressed,
                backgroundColor: theme.backgroundColor,
                heroTag: null,
                mini: true,
                child: Icon(
                  Icons.delete_forever,
                  color: theme.errorColor,
                  size: 18,
                ),
              ),
            ],
          ),
        );

    Widget buildDealCategory() => Text(
          l(context).atCategory(
            _categories.getCategoryNameFromCategory(
              category: deal.category,
              locale: Localizations.localeOf(context),
            ),
          ),
          style: textTheme.subtitle1!.copyWith(
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        );

    Widget buildDealPrice() => Row(
          children: [
            Text(
              '\$${deal.price.toStringAsFixed(0)}',
              style: textTheme.headline5!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '\$${deal.originalPrice.toStringAsFixed(0)}',
              style: textTheme.subtitle2!.copyWith(
                color: theme.errorColor,
                decoration: TextDecoration.lineThrough,
                fontSize: 12,
              ),
            ),
          ],
        );

    Widget buildDealScore() => Row(
          children: [
            const Icon(FontAwesomeIcons.thumbsUp, size: 14),
            const SizedBox(width: 4),
            Text(
              _dealScore.toString(),
              style: textTheme.subtitle2!.copyWith(fontSize: 12),
            ),
          ],
        );

    Widget buildSeparator() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            '|',
            style: textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w300),
          ),
        );

    Widget buildCommentsCount() => Row(
          children: [
            const Icon(FontAwesomeIcons.comment, size: 14),
            const SizedBox(width: 4),
            Text(
              _commentsCount.toString(),
              style: textTheme.subtitle2!.copyWith(fontSize: 12),
            )
          ],
        );

    Widget buildViewsCount() => Row(
          children: [
            const Icon(FontAwesomeIcons.solidEye, size: 14),
            const SizedBox(width: 4),
            Text(
              _viewsCount.toString(),
              style: textTheme.subtitle2!.copyWith(fontSize: 12),
            ),
          ],
        );

    Widget buildDealDetails() => Row(
          children: [
            buildDealCoverPhoto(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDealTitle(),
                    const SizedBox(height: 3),
                    buildDealCategory(),
                    const SizedBox(height: 8),
                    buildDealPrice(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        buildDealScore(),
                        buildSeparator(),
                        buildCommentsCount(),
                        buildSeparator(),
                        buildViewsCount(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

    Widget buildFavoriteButton() => Positioned(
          right: 0,
          top: 88,
          child: FloatingActionButton(
            onPressed: widget.onFavoriteButtonPressed,
            backgroundColor: theme.backgroundColor,
            heroTag: null,
            mini: true,
            child: Icon(
              widget.isFavorited
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              color: theme.primaryColor,
              size: 18,
            ),
          ),
        );

    Widget buildSpecialMark() => Positioned(
          left: 10,
          top: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                deal.status == DealStatus.expired
                    ? l(context).expired
                    : l(context).newMark,
                style: textTheme.bodyText2!
                    .copyWith(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        );

    Widget buildDealContent() => SizedBox(
          height: 120,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: InkWell(
              onTap: () => NavigationUtil.navigate(
                context,
                DealDetails(dealId: deal.id!),
              ).then((_) => widget.pagingController.refresh()),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: buildDealDetails(),
            ),
          ),
        );

    Widget buildStack() => Stack(
          clipBehavior: Clip.none,
          children: [
            buildDealContent(),
            if (widget.showControlButtons) buildControlButtons(),
            buildFavoriteButton(),
            if (deal.status == DealStatus.expired || deal.isNew!)
              buildSpecialMark(),
          ],
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 145,
        width: deviceWidth,
        child: deal.status == DealStatus.expired
            ? Opacity(
                opacity: .7,
                child: GrayscaleColorFiltered(
                  child: buildStack(),
                ),
              )
            : buildStack(),
      ),
    );
  }
}
