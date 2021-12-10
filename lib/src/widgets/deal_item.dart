import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import '../deal/deal_details.dart';
import '../models/categories.dart';
import '../models/deal.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';
import '../utils/navigation_util.dart';

class DealItem extends StatefulWidget {
  const DealItem({
    Key? key,
    this.onTap,
    required this.deal,
    this.inactiveMessage,
    required this.index,
    required this.isFavorited,
    required this.onFavoriteButtonPressed,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Deal deal;
  final String? inactiveMessage;
  final int index;
  final bool isFavorited;
  final VoidCallback onFavoriteButtonPressed;

  @override
  _DealItemState createState() => _DealItemState();
}

class _DealItemState extends State<DealItem> {
  int _commentsCount = 0;
  late Categories _categories;

  @override
  void initState() {
    _categories = GetIt.I.get<Categories>();
    _updateCommentsCount();
    super.initState();
  }

  void _updateCommentsCount() {
    GetIt.I
        .get<SpringService>()
        .getNumberOfCommentsByDealId(dealId: widget.deal.id!)
        .then((int? commentsCount) {
      if (commentsCount != null) {
        WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          if (mounted) {
            setState(() {
              _commentsCount = commentsCount;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;
    final Deal deal = widget.deal;

    Widget buildDealCoverPhoto() {
      return Container(
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
        child: Hero(
          tag: deal.id!,
          child: Image.network(deal.coverPhoto, fit: BoxFit.cover),
        ),
      );
    }

    Widget buildDealTitle() {
      return SizedBox(
        width: deviceWidth * .65,
        child: Text(
          deal.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: textTheme.headline6!.copyWith(fontSize: 18),
        ),
      );
    }

    Widget buildDealCategory() {
      return Text(
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
    }

    Widget buildDealPrice() {
      return Row(
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
    }

    Widget buildDealScore() {
      return Row(
        children: [
          const Icon(FontAwesomeIcons.thumbsUp, size: 14),
          const SizedBox(width: 4),
          Text(
            deal.dealScore.toString(),
            style: textTheme.subtitle2!.copyWith(fontSize: 12),
          ),
        ],
      );
    }

    Widget buildSeparator() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          '|',
          style: textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w300),
        ),
      );
    }

    Widget buildCommentsCount() {
      return Row(
        children: [
          const Icon(FontAwesomeIcons.comment, size: 14),
          const SizedBox(width: 4),
          Text(
            _commentsCount.toString(),
            style: textTheme.subtitle2!.copyWith(fontSize: 12),
          )
        ],
      );
    }

    Widget buildViewsCount() {
      return Row(
        children: [
          const Icon(FontAwesomeIcons.solidEye, size: 14),
          const SizedBox(width: 4),
          Text(
            deal.views.toString(),
            style: textTheme.subtitle2!.copyWith(fontSize: 12),
          ),
        ],
      );
    }

    Widget buildDealDetails() {
      return Row(
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
    }

    Widget buildFavoriteButton() {
      return Positioned(
        right: 0,
        top: 88,
        child: FloatingActionButton(
          onPressed: widget.onFavoriteButtonPressed,
          backgroundColor: theme.backgroundColor,
          heroTag: 'btn${widget.index}',
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
    }

    Widget buildInactiveMessage() {
      return Positioned(
        left: 0,
        top: 124,
        child: Text(widget.inactiveMessage!),
      );
    }

    Widget buildSpecialMark() {
      return Positioned(
        left: 10,
        top: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.primaryColor,
          ),
          child: Text(
            l(context).newMark,
            style: textTheme.bodyText2!
                .copyWith(color: Colors.white, fontSize: 11),
          ),
        ),
      );
    }

    Widget buildDealContent() {
      return SizedBox(
        height: 120,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: widget.onTap ??
                () => NavigationUtil.navigate(context, DealDetails(deal: deal)),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: buildDealDetails(),
          ),
        ),
      );
    }

    return Container(
      height: 145,
      width: deviceWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Opacity(
        opacity: widget.inactiveMessage == null ? 1 : .6,
        child: Stack(
          children: [
            buildDealContent(),
            buildFavoriteButton(),
            if (widget.inactiveMessage != null) buildInactiveMessage(),
            if (deal.isNew!) buildSpecialMark()
          ],
        ),
      ),
    );
  }
}
