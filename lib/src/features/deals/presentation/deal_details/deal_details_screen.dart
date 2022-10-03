import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:url_launcher/url_launcher.dart';

import '../../../../common_widgets/custom_snack_bar.dart';
import '../../../../common_widgets/error_indicator.dart';
import '../../../../common_widgets/expandable_text.dart';
import '../../../../common_widgets/user_profile_dialog.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../../helpers/date_time_helper.dart';
import '../../../auth/domain/my_user.dart';
import '../../../auth/presentation/user_controller.dart';
import '../../../browse/data/categories_provider.dart';
import '../../../browse/data/stores_provider.dart';
import '../../../browse/domain/store.dart';
import '../../../settings/presentation/locale_controller.dart';
import '../../domain/comment.dart';
import '../../domain/deal.dart';
import 'deal_details_controller.dart';
import 'widgets/carousel_slider_indicator.dart';
import 'widgets/comment_paged_sliver_list.dart';
import 'widgets/deal_details_screen_appbar.dart';
import 'widgets/post_comment_dialog.dart';

class DealDetailsScreen extends ConsumerStatefulWidget {
  const DealDetailsScreen({required this.dealId, super.key});

  final String dealId;

  @override
  ConsumerState<DealDetailsScreen> createState() => _DealDetailsScreenState();
}

class _DealDetailsScreenState extends ConsumerState<DealDetailsScreen> {
  final _pagingController = PagingController<int, Comment>(firstPageKey: 0);
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() => setState(
          () => _showScrollToTopButton = _scrollController.offset >= 1000));
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deal = ref.watch(dealDetailsControllerProvider(widget.dealId));
    return deal.when(
      data: (deal) {
        if (deal == null) return _DealError(widget.dealId);
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: DealDetailsScreenAppBar(deal: deal),
          ),
          body: Column(
            children: [
              if (deal.status == DealStatus.expired) _DealExpiredBanner(),
              Flexible(
                child: Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: _DealDetailsBody(
                            deal: deal,
                            pagingController: _pagingController,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          sliver: _DealCommentsListView(
                            deal: deal,
                            pagingController: _pagingController,
                          ),
                        ),
                      ],
                    ),
                    if (_showScrollToTopButton)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            onPressed: () => _scrollController.animateTo(
                              0,
                              curve: Curves.decelerate,
                              duration: const Duration(milliseconds: 500),
                            ),
                            mini: true,
                            child: const Icon(Icons.expand_less),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(deal.dealUrl!);
                    await canLaunchUrl(uri)
                        ? await launchUrl(uri)
                        : throw Exception('Could not launch $uri');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.secondary,
                    fixedSize: Size(context.mq.size.width, 50),
                  ),
                  child: Text(context.l.seeDeal),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _DealError(widget.dealId),
    );
  }
}

class _DealError extends ConsumerWidget {
  const _DealError(this.dealId);

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: NoConnectionError(
        onPressed: () => ref.refresh(dealDetailsControllerProvider(dealId)),
      ),
    );
  }
}

class _DealExpiredBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ColoredBox(
        color: context.isDarkMode
            ? context.t.primaryColorDark
            : context.t.colorScheme.secondary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              context.l.thisDealHasExpired,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({required this.deal});

  final Deal deal;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  var currentIndex = 0;
  late List<String> images;

  @override
  void initState() {
    images = [widget.deal.coverPhoto, ...widget.deal.photos ?? []];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          items: images
              .map(
                (url) => GestureDetector(
                  onTap: () => context.go(
                    '/deals/${widget.deal.id}/images?index=$currentIndex',
                    extra: images,
                  ),
                  child: Image.network(url, fit: BoxFit.cover),
                ),
              )
              .toList(),
          options: CarouselOptions(
            enlargeCenterPage: true,
            height: context.mq.size.height / 2,
            onPageChanged: (index, _) => setState(() => currentIndex = index),
            viewportFraction: 1,
          ),
        ),
        if (images.length > 1)
          CarouselSliderIndicator(currentIndex: currentIndex, imageUrls: images)
      ],
    );
  }
}

class _DealCreatedAt extends StatelessWidget {
  const _DealCreatedAt({required this.createdAt});

  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final locale = ref.watch(localeControllerProvider);
        return Text(
          formatDateTime(
            createdAt,
            locale: locale,
            useShortMessages: false,
          ),
          style: context.textTheme.bodyText2!.copyWith(
            color: context.isLightMode ? Colors.black54 : Colors.grey,
            fontSize: 12,
          ),
        );
      },
    );
  }
}

class _DealScore extends StatelessWidget {
  const _DealScore({required this.score});

  final int score;

  Color _boxColorFromScore(int score) {
    if (score < 0) return Colors.red;
    if (score == 0) return Colors.grey;
    return const Color(0xFF006400).withOpacity(.8);
  }

  @override
  Widget build(BuildContext context) {
    final scoreText = score > 0 ? '+$score' : score.toString();
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _boxColorFromScore(score),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Text(
            scoreText,
            style: context.textTheme.bodyText2!
                .copyWith(color: Colors.green.shade50),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          context.l.dealScore,
          style: context.textTheme.bodyText2!.copyWith(
            color: context.isLightMode ? Colors.black54 : Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        backgroundColor: context.isLightMode ? Colors.black54 : Colors.grey,
        radius: 1.5,
      ),
    );
  }
}

class _DealDetailsBody extends ConsumerWidget {
  const _DealDetailsBody({required this.deal, required this.pagingController});

  final Deal deal;
  final PagingController<int, Comment> pagingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentCount = ref.watch(dealCommentsByIdFutureProvider(deal.id!));
    final user = ref.watch(userProvider)!;
    final store = ref.watch(storesProvider).storeByStoreId(deal.store);
    final poster = ref.watch(userByIdFutureProvider(deal.postedBy!));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Carousel(deal: deal),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    direction: Axis.vertical,
                    spacing: 10,
                    children: [
                      _DealCreatedAt(createdAt: deal.createdAt!),
                      Row(
                        children: [
                          _DealScore(score: deal.dealScore!),
                          _Separator(),
                          Text(
                            context.l
                                .commentCount(commentCount.value?.count ?? 0),
                            style: context.textTheme.bodyText2!.copyWith(
                              color: context.t.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _Separator(),
                          Icon(
                            FontAwesomeIcons.solidEye,
                            color: context.t.primaryColorLight,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            deal.views.toString(),
                            style: context.textTheme.subtitle2!.copyWith(
                              color: context.isLightMode
                                  ? Colors.black54
                                  : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _StoreImage(dealId: deal.id!, store: store),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DealTitle(title: deal.title),
                        const SizedBox(height: 5),
                        _DealCategory(category: deal.category),
                        const SizedBox(height: 5),
                        _DealPrices(deal: deal),
                      ],
                    ),
                  ),
                  _FavoriteButton(dealId: deal.id!),
                ],
              ),
              Card(
                child: ExpandableText(text: deal.description),
              ),
              _VoteDeal(deal: deal, userId: user.id!),
              poster.when(
                data: (data) => _PosterDetails(poster: data),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) =>
                    Center(child: Text(context.l.anErrorOccurred)),
              ),
              _CommentHeader(
                commentCount: commentCount.value?.count ?? 0,
                deal: deal,
                pagingController: pagingController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoreImage extends StatelessWidget {
  const _StoreImage({required this.dealId, required this.store});

  final String dealId;
  final Store store;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(
        '/deals/$dealId/store-image?url=${Uri.encodeComponent(store.logo)}',
      ),
      child: CachedNetworkImage(
        height: 45,
        width: 45,
        imageBuilder: (ctx, imageProvider) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: context.isDarkMode ? Colors.white : null,
            image: DecorationImage(image: imageProvider),
          ),
        ),
        placeholder: (context, url) => const SizedBox.square(dimension: 40),
        imageUrl: store.logo,
      ),
    );
  }
}

class _DealTitle extends StatelessWidget {
  const _DealTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style:
          context.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _DealCategory extends ConsumerWidget {
  const _DealCategory({required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Text(
      categories.categoryNameFromCategory(
        category: category,
        locale: Localizations.localeOf(context),
      ),
      style: context.textTheme.bodyText2!.copyWith(
        color: context.isLightMode ? Colors.black54 : Colors.grey,
      ),
    );
  }
}

class _DealPrices extends StatelessWidget {
  const _DealPrices({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(
          r'$' + deal.price.toStringAsFixed(0),
          style: context.textTheme.headline5!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          r'$' + deal.originalPrice.toStringAsFixed(0),
          style: context.textTheme.subtitle2!.copyWith(
            color: context.t.errorColor,
            decoration: TextDecoration.lineThrough,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.dealId});

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isFavorited = user.favorites?.contains(dealId) ?? false;

    return MaterialButton(
      onPressed: () => ref
          .read(dealDetailsControllerProvider(dealId).notifier)
          .onFavoriteButtonPressed(
            isFavorited: isFavorited,
            onSuccess: ref.read(userProvider.notifier).refreshUser,
          ),
      color: context.t.backgroundColor,
      elevation: 8,
      height: 50,
      minWidth: 50,
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
      child: Icon(
        isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
        color: context.t.primaryColor,
      ),
    );
  }
}

class _VoteDeal extends ConsumerStatefulWidget {
  const _VoteDeal({required this.deal, required this.userId});

  final Deal deal;
  final String userId;

  @override
  ConsumerState<_VoteDeal> createState() => _VoteDealState();
}

class _VoteDealState extends ConsumerState<_VoteDeal> {
  var isUpvoted = false;
  var isDownvoted = false;

  @override
  void initState() {
    isUpvoted = widget.deal.upvoters!.contains(widget.userId);
    isDownvoted = widget.deal.downvoters!.contains(widget.userId);
    super.initState();
  }

  void voteDeal(DealVoteType voteType) {
    final previousIsUpvoted = isUpvoted;
    final previousIsDownVoted = isDownvoted;

    setState(() {
      switch (voteType) {
        case DealVoteType.up:
          isUpvoted = true;
          isDownvoted = false;
          break;
        case DealVoteType.down:
          isUpvoted = false;
          isDownvoted = true;
          break;
        case DealVoteType.unvote:
          isUpvoted = false;
          isDownvoted = false;
          break;
      }
    });

    ref.read(dealDetailsControllerProvider(widget.deal.id!).notifier).voteDeal(
          voteType,
          onSuccess: () =>
              ref.invalidate(dealByIdFutureProvider(widget.deal.id!)),
          onFailure: () {
            setState(() {
              isUpvoted = previousIsUpvoted;
              isDownvoted = previousIsDownVoted;
            });
            const CustomSnackBar.error().showSnackBar(context);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        children: [
          Text(
            context.l.didYouLikeTheDeal,
            style: context.textTheme.bodyText2!.copyWith(
              color: context.isLightMode ? Colors.black54 : Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: () =>
                voteDeal(isUpvoted ? DealVoteType.unvote : DealVoteType.up),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isUpvoted ? Colors.green : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
                color: context.isLightMode
                    ? Colors.grey.shade300
                    : context.t.primaryColor.withOpacity(.5),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                FontAwesomeIcons.solidThumbsUp,
                color: isUpvoted ? Colors.green : Colors.grey,
                size: 16,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                voteDeal(isDownvoted ? DealVoteType.unvote : DealVoteType.down),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDownvoted
                      ? Colors.pinkAccent.shade100
                      : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
                color: context.isLightMode
                    ? Colors.grey.shade300
                    : context.t.primaryColor.withOpacity(.5),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                FontAwesomeIcons.solidThumbsDown,
                color: isDownvoted ? Colors.pinkAccent.shade100 : Colors.grey,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterDetails extends StatelessWidget {
  const _PosterDetails({required this.poster});

  final MyUser poster;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => UserProfileDialog(userId: poster.id!),
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: poster.avatar!,
            imageBuilder: (ctx, imageProvider) =>
                CircleAvatar(backgroundImage: imageProvider),
            placeholder: (context, url) => const CircleAvatar(),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.green.shade600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 1,
                ),
                child: Text(
                  context.l.originalPoster,
                  style: context.textTheme.bodyText2!.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                poster.nickname!,
                style: context.textTheme.subtitle2!.copyWith(
                  color: context.isLightMode ? context.t.primaryColor : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentHeader extends ConsumerWidget {
  const _CommentHeader({
    required this.commentCount,
    required this.deal,
    required this.pagingController,
  });

  final int commentCount;
  final Deal deal;
  final PagingController<int, Comment> pagingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l.commentCount(commentCount),
              style: context.textTheme.subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => PostCommentDialog(deal: deal),
              ).then((_) {
                ref.invalidate(dealCommentsByIdFutureProvider(deal.id!));
                pagingController.refresh();
              }),
              child: Text(
                context.l.postComment,
                style: context.textTheme.subtitle2!.copyWith(
                    color: context.isLightMode
                        ? context.t.primaryColor
                        : context.t.primaryColorLight),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class _DealCommentsListView extends ConsumerWidget {
  const _DealCommentsListView(
      {required this.deal, required this.pagingController});

  final Deal deal;
  final PagingController<int, Comment> pagingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommentPagedListView(
      commentFuture: (int page, int size) =>
          ref.read(hotdealsRepositoryProvider).getDealComments(
                dealId: deal.id!,
                page: page,
                size: size,
              ),
      noCommentsFound: ErrorIndicator(
        icon: Icons.comment_outlined,
        title: context.l.noComments,
        message: context.l.startTheConversation,
      ),
      pagingController: pagingController,
    );
  }
}
