import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../../../../common_widgets/grayscale_filtered.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../browse/data/categories_provider.dart';
import '../../domain/deal.dart';

class DealItem extends StatelessWidget {
  const DealItem({
    required this.deal,
    required this.index,
    required this.isFavorited,
    required this.onEditButtonPressed,
    required this.onFavoriteButtonPressed,
    required this.onDeleteButtonPressed,
    required this.pagingController,
    required this.showControlButtons,
    super.key,
  });

  final Deal deal;
  final int index;
  final bool isFavorited;
  final VoidCallback onEditButtonPressed;
  final VoidCallback onFavoriteButtonPressed;
  final VoidCallback onDeleteButtonPressed;
  final PagingController pagingController;
  final bool showControlButtons;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 145,
        child: Stack(
          children: [
            if (deal.status == DealStatus.expired)
              Opacity(
                opacity: .75,
                child: GrayscaleColorFiltered(
                  child: _Stack(deal: deal),
                ),
              )
            else
              _Stack(deal: deal),
            if (showControlButtons)
              Positioned(
                right: 48,
                top: 88,
                child: Row(
                  children: [
                    MaterialButton(
                      onPressed: onEditButtonPressed,
                      color: context.t.backgroundColor,
                      elevation: 8,
                      height: 40,
                      minWidth: 40,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      child: Icon(
                        Icons.edit,
                        color:
                            context.isDarkMode ? null : context.t.primaryColor,
                        size: 18,
                      ),
                    ),
                    MaterialButton(
                      onPressed: onDeleteButtonPressed,
                      color: context.t.backgroundColor,
                      elevation: 8,
                      height: 40,
                      minWidth: 40,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      child: Icon(
                        Icons.delete_forever,
                        color: context.t.errorColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              right: 0,
              top: 88,
              child: MaterialButton(
                onPressed: onFavoriteButtonPressed,
                color: context.t.backgroundColor,
                elevation: 8,
                height: 40,
                minWidth: 40,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                child: Icon(
                  isFavorited
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  color: context.t.primaryColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.t.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          title,
          style: context.textTheme.bodyText2!
              .copyWith(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}

class _Stack extends ConsumerWidget {
  const _Stack({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final currentDeal = ref.watch(dealByIdFutureProvider(deal.id!));
    final dealComments = ref.watch(dealCommentsByIdFutureProvider(deal.id!));

    return Stack(
      children: [
        SizedBox(
          height: 120,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              onTap: () => context.go('/deals/${deal.id}'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              isThreeLine: true,
              leading: _DealCover(photoUrl: deal.coverPhoto),
              title: Text(
                deal.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: context.textTheme.headline6!.copyWith(fontSize: 18),
              ),
              subtitle: Wrap(
                runSpacing: 8,
                children: [
                  _Category(categories: categories, deal: deal),
                  _Prices(deal: deal),
                  Row(
                    children: [
                      _DealScore(
                        currentDeal.value?.dealScore.toString() ?? '0',
                      ),
                      const _Separator(),
                      _CommentCount(
                        dealComments.value?.count.toString() ?? '0',
                      ),
                      const _Separator(),
                      _ViewCount(
                        currentDeal.value?.views.toString() ?? '0',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (deal.status == DealStatus.expired || deal.isNew!)
          Positioned(
            left: 10,
            top: 10,
            child: _Mark(
              title: deal.status == DealStatus.expired
                  ? context.l.expired
                  : context.l.newMark,
            ),
          ),
      ],
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({required this.categories, required this.deal});

  final CategoriesController categories;
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l.atCategory(
        categories.categoryNameFromCategory(
          category: deal.category,
          locale: Localizations.localeOf(context),
        ),
      ),
      style: context.textTheme.subtitle1!.copyWith(
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _Prices extends StatelessWidget {
  const _Prices({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          r'$' + deal.price.toStringAsFixed(0),
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          r'$' + deal.originalPrice.toStringAsFixed(0),
          style: context.textTheme.subtitle2!.copyWith(
            color: context.t.errorColor,
            decoration: TextDecoration.lineThrough,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        '|',
        style:
            context.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w300),
      ),
    );
  }
}

class _DealScore extends StatelessWidget {
  const _DealScore(this.score);

  final String score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.thumbsUp, size: 14),
        const SizedBox(width: 4),
        Text(
          score,
          style: context.textTheme.subtitle2!.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _CommentCount extends StatelessWidget {
  const _CommentCount(this.count);

  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.comment, size: 14),
        const SizedBox(width: 4),
        Text(
          count,
          style: context.textTheme.subtitle2!.copyWith(fontSize: 12),
        )
      ],
    );
  }
}

class _ViewCount extends StatelessWidget {
  const _ViewCount(this.count);

  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.solidEye, size: 14),
        const SizedBox(width: 4),
        Text(
          count,
          style: context.textTheme.subtitle2!.copyWith(fontSize: 12),
        )
      ],
    );
  }
}

class _DealCover extends StatelessWidget {
  const _DealCover({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        photoUrl,
        fit: BoxFit.cover,
        height: 60,
        width: 60,
      ),
    );
  }
}
