import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/categories.dart';
import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/store.dart';
import '../models/stores.dart';
import '../models/user_controller.dart';
import '../services/api_repository.dart';
import '../services/firebase_storage_service.dart';
import '../utils/date_time_util.dart';
import '../utils/error_indicator_util.dart';
import '../utils/localization_util.dart';
import '../utils/navigation_util.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/expandable_text.dart';
import '../widgets/image_fullscreen.dart';
import '../widgets/sign_in_dialog.dart';
import '../widgets/slider_indicator.dart';
import '../widgets/user_profile_dialog.dart';
import 'deal_comments.dart';
import 'deal_score_box.dart';
import 'images_fullscreen.dart';
import 'post_comment.dart';
import 'report_deal_dialog.dart';
import 'update_deal.dart';

enum _DealPopup {
  deleteDeal,
  markAsActive,
  markAsExpired,
  reportDeal,
  updateDeal
}

class DealDetails extends StatefulWidget {
  const DealDetails({required this.dealId, Key? key}) : super(key: key);

  final String dealId;

  @override
  _DealDetailsState createState() => _DealDetailsState();
}

class _DealDetailsState extends State<DealDetails> {
  final _pagingController = PagingController<int, Comment>(firstPageKey: 0);
  Deal? _deal;
  late Future<Deal?> _dealFuture;
  late Future<int?> _commentCountFuture;
  List<String>? _images;
  int currentIndex = 0;
  late Categories _categories;
  Store? _store;
  late MyUser? _user;
  int? _commentCount;
  bool isUpvoted = false;
  bool isDownvoted = false;
  bool _showScrollToTopButton = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    _dealFuture = GetIt.I.get<APIRepository>().getDeal(dealId: widget.dealId);
    _commentCountFuture =
        GetIt.I.get<APIRepository>().getDealCommentCount(dealId: widget.dealId);
    _categories = GetIt.I.get<Categories>();
    _user = context.read<UserController>().user;
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

  void _updateCommentsCount() {
    GetIt.I
        .get<APIRepository>()
        .getDealCommentCount(dealId: widget.dealId)
        .then((commentCount) {
      if (commentCount != null) {
        if (mounted) {
          setState(() => _commentCount = commentCount);
        }
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  List<Widget> getCarouselItems() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return _images!
        .map((item) => GestureDetector(
              onTap: () => NavigationUtil.navigate(
                context,
                DealImagesFullScreen(
                  images: _images!,
                  currentIndex: currentIndex,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  color: isDarkMode ? Colors.white : null,
                ),
                padding: isDarkMode ? const EdgeInsets.all(2) : null,
                child: Image.network(item, fit: BoxFit.cover),
              ),
            ))
        .toList();
  }

  Future<void> _updateDealStatus(DealStatus status) async {
    try {
      final deal = await GetIt.I.get<APIRepository>().updateDealStatus(
            dealId: _deal!.id!,
            status: status,
          );
      if (mounted) {
        setState(() => _deal = deal);
      }
      final snackBar = CustomSnackBar(
        icon: const Icon(FontAwesomeIcons.circleCheck, size: 20),
        text: status == DealStatus.active
            ? l(context).markAsActiveSuccess
            : l(context).markAsExpiredSuccess,
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on Exception {
      final snackBar = CustomSnackBar(
        icon: const Icon(FontAwesomeIcons.circleExclamation, size: 20),
        text: l(context).anErrorOccurred,
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _onPressedReport() async => showDialog<void>(
        context: context,
        builder: (context) => ReportDealDialog(reportedDealId: _deal!.id!),
      );

  void _onUpdateButtonPressed(Deal deal) =>
      NavigationUtil.navigate(context, UpdateDeal(deal: deal));

  Future<void> _onDeleteButtonPressed(MyUser? user, Deal deal) async {
    if (user == null) {
      GetIt.I.get<SignInDialog>().showSignInDialog(context);
      return;
    }

    final didRequestDelete = await CustomAlertDialog(
          title: l(context).deleteConfirm,
          cancelActionText: l(context).cancel,
          defaultActionText: l(context).delete,
        ).show(context) ??
        false;
    if (didRequestDelete) {
      GetIt.I
          .get<APIRepository>()
          .deleteDeal(dealId: deal.id!)
          .then((result) async {
        // Deletes the deal images.
        await GetIt.I
            .get<FirebaseStorageService>()
            .deleteImagesFromUrl(urls: [deal.coverPhoto, ...deal.photos!]);
        if (result) {
          _pagingController.refresh();
          Navigator.of(context).pop();
        } else {
          final snackBar = CustomSnackBar(
            icon: const Icon(FontAwesomeIcons.circleExclamation, size: 20),
            text: l(context).deleteDealError,
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    PreferredSizeWidget _buildAppBar() {
      late final List<PopupMenuItem<_DealPopup>> items;
      if (_user == null) {
        items = [];
      } else {
        final userIsPoster = _user!.id! == _deal!.postedBy!;
        items = <PopupMenuItem<_DealPopup>>[
          if (userIsPoster) ...[
            if (_deal!.status == DealStatus.expired)
              PopupMenuItem<_DealPopup>(
                value: _DealPopup.markAsActive,
                child: Text(l(context).markAsActive),
              )
            else if (_deal!.status == DealStatus.active)
              PopupMenuItem<_DealPopup>(
                value: _DealPopup.markAsExpired,
                child: Text(l(context).markAsExpired),
              ),
            PopupMenuItem<_DealPopup>(
              value: _DealPopup.updateDeal,
              child: Text(l(context).updateDeal),
            ),
            PopupMenuItem<_DealPopup>(
              value: _DealPopup.deleteDeal,
              child: Text(l(context).deleteDeal),
            ),
          ],
          if (!userIsPoster)
            PopupMenuItem<_DealPopup>(
              value: _DealPopup.reportDeal,
              child: Text(l(context).reportDeal),
            ),
        ];
      }

      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          actions: [
            if (items.isNotEmpty)
              PopupMenuButton<_DealPopup>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => items,
                onSelected: (result) {
                  switch (result) {
                    case _DealPopup.deleteDeal:
                      _onDeleteButtonPressed(_user, _deal!);
                      break;
                    case _DealPopup.markAsActive:
                      _updateDealStatus(DealStatus.active);
                      break;
                    case _DealPopup.markAsExpired:
                      _updateDealStatus(DealStatus.expired);
                      break;
                    case _DealPopup.reportDeal:
                      _onPressedReport();
                      break;
                    case _DealPopup.updateDeal:
                      _onUpdateButtonPressed(_deal!);
                      break;
                  }
                },
              ),
          ],
          centerTitle: true,
          title: Text(_deal!.title),
        ),
      );
    }

    Widget buildDealImages() => Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
              items: getCarouselItems(),
              options: CarouselOptions(
                viewportFraction: 1,
                height: deviceHeight / 2,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) =>
                    setState(() => currentIndex = index),
              ),
            ),
            if (_images!.length > 1)
              SliderIndicator(images: _images!, currentIndex: currentIndex)
          ],
        );

    Widget buildDealDescription() => Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          child: ExpandableText(text: _deal!.description),
        );

    Widget buildStoreImage() => GestureDetector(
          onTap: () => NavigationUtil.navigate(
            context,
            ImageFullScreen(imageUrl: _store!.logo, heroTag: _store!.id!),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              color: theme.brightness == Brightness.dark ? Colors.white : null,
            ),
            padding: theme.brightness == Brightness.dark
                ? const EdgeInsets.all(3)
                : null,
            height: 45,
            width: 45,
            child: CachedNetworkImage(
              imageUrl: _store!.logo,
              imageBuilder: (ctx, imageProvider) => Hero(
                tag: _store!.id!,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider),
                  ),
                ),
              ),
              placeholder: (context, url) =>
                  const SizedBox.square(dimension: 40),
            ),
          ),
        );

    Widget buildFavoriteButton() => Consumer<UserController>(
          builder: (context, mongoUser, child) {
            final user = mongoUser.user;
            final isFavorited = user?.favorites!.contains(_deal!.id!) ?? false;

            return FloatingActionButton(
              onPressed: () {
                if (_user == null) {
                  GetIt.I.get<SignInDialog>().showSignInDialog(context);

                  return;
                }
                if (!isFavorited) {
                  GetIt.I
                      .get<APIRepository>()
                      .favoriteDeal(dealId: _deal!.id!)
                      .then((result) {
                    if (result) {
                      Provider.of<UserController>(context, listen: false)
                          .getUser();
                    }
                  });
                } else {
                  GetIt.I
                      .get<APIRepository>()
                      .unfavoriteDeal(dealId: _deal!.id!)
                      .then((result) {
                    if (result) {
                      Provider.of<UserController>(context, listen: false)
                          .getUser();
                    }
                  });
                }
              },
              heroTag: null,
              backgroundColor: theme.backgroundColor,
              elevation: 3,
              child: Icon(
                isFavorited
                    ? FontAwesomeIcons.solidHeart
                    : FontAwesomeIcons.heart,
                color: theme.primaryColor,
              ),
            );
          },
        );

    Widget buildDealDetails() => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateTimeUtil.formatDateTime(_deal!.createdAt!,
                            useShortMessages: false),
                        style: textTheme.bodyText2!.copyWith(
                          color: theme.brightness == Brightness.light
                              ? Colors.black54
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          DealScoreBox(score: _deal!.dealScore!),
                          const SizedBox(width: 5),
                          Text(
                            l(context).dealScore,
                            style: textTheme.bodyText2!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '???',
                              style: textTheme.bodyText2!.copyWith(
                                color: theme.brightness == Brightness.light
                                    ? Colors.black54
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            l(context).commentCount(_commentCount!),
                            style: textTheme.bodyText2!.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '???',
                              style: textTheme.bodyText2!.copyWith(
                                color: theme.brightness == Brightness.light
                                    ? Colors.black54
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Icon(FontAwesomeIcons.solidEye,
                              color: theme.primaryColorLight, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _deal!.views.toString(),
                            style: textTheme.subtitle2!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  buildStoreImage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: deviceWidth * .7,
                        child: Text(
                          _deal!.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headline6!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _categories.getCategoryNameFromCategory(
                          category: _deal!.category,
                          locale: Localizations.localeOf(context),
                        ),
                        style: textTheme.bodyText2!.copyWith(
                          color: theme.brightness == Brightness.light
                              ? Colors.black54
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            r'$' + _deal!.price.toStringAsFixed(0),
                            style: textTheme.headline5!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            r'$' + _deal!.originalPrice.toStringAsFixed(0),
                            style: textTheme.subtitle2!.copyWith(
                              color: theme.errorColor,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  buildFavoriteButton(),
                ],
              ),
            ),
            buildDealDescription(),
          ],
        );

    Future<void> voteDeal(DealVoteType voteType) async {
      if (_user == null) {
        GetIt.I.get<SignInDialog>().showSignInDialog(context);

        return;
      }
      final deal = await GetIt.I.get<APIRepository>().voteDeal(
            dealId: _deal!.id!,
            voteType: voteType,
          );
      if (deal == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.circleExclamation, size: 20),
          text: l(context).anErrorOccurred,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        if (mounted) {
          setState(() {
            _deal = deal;
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
        }
      }
    }

    Widget buildRateDeal() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                l(context).didYouLikeTheDeal,
                style: textTheme.bodyText2!.copyWith(
                  color: theme.brightness == Brightness.light
                      ? Colors.black54
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () =>
                    voteDeal(isUpvoted ? DealVoteType.unvote : DealVoteType.up),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isUpvoted ? Colors.green : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    color: theme.brightness == Brightness.light
                        ? Colors.grey.shade300 //theme.primaryColor
                        : theme.primaryColor.withOpacity(.5),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    FontAwesomeIcons.solidThumbsUp,
                    color: isUpvoted ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => voteDeal(
                    isDownvoted ? DealVoteType.unvote : DealVoteType.down),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDownvoted
                          ? Colors.pinkAccent.shade100
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    color: theme.brightness == Brightness.light
                        ? Colors.grey.shade300 //theme.primaryColor
                        : theme.primaryColor.withOpacity(.5),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    FontAwesomeIcons.solidThumbsDown,
                    color:
                        isDownvoted ? Colors.pinkAccent.shade100 : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );

    Future<void> _onUserTap(String userId) async => showDialog<void>(
          context: context,
          builder: (context) => UserProfileDialog(userId: userId),
        );

    Widget buildUserDetails() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<MyUser>(
            future:
                GetIt.I.get<APIRepository>().getUserById(id: _deal!.postedBy!),
            builder: (context, snapshot) {
              var avatar = 'http://www.gravatar.com/avatar';
              var nickname = '...';
              VoidCallback? onTap;

              if (snapshot.hasData) {
                final user = snapshot.data!;
                onTap = () => _onUserTap(user.id!);
                avatar = user.avatar!;
                nickname = user.nickname!;
              } else if (snapshot.hasError) {
                nickname = l(context).anErrorOccurred;
              }

              return GestureDetector(
                onTap: _user == null
                    ? () =>
                        GetIt.I.get<SignInDialog>().showSignInDialog(context)
                    : onTap,
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: avatar,
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(2)),
                            color: Colors.green.shade600,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 1,
                          ),
                          child: Text(
                            l(context).originalPoster,
                            style: textTheme.bodyText2!.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          nickname,
                          style: textTheme.subtitle2!.copyWith(
                            color: theme.brightness == Brightness.light
                                ? theme.primaryColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );

    Widget buildCommentCounts() {
      final textTheme = Theme.of(context).textTheme;

      return Text(
        l(context).commentCount(_commentCount!),
        style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
      );
    }

    void _onPostCommentTap() {
      if (_user == null) {
        GetIt.I.get<SignInDialog>().showSignInDialog(context);

        return;
      }

      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: PostComment(deal: _deal!),
        ),
      ).then((_) {
        _updateCommentsCount();
        _pagingController.refresh();
      });
    }

    Widget buildPostCommentButton() {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;

      return TextButton(
        onPressed: _onPostCommentTap,
        child: Text(
          l(context).postComment,
          style: textTheme.subtitle2!.copyWith(
              color: theme.brightness == Brightness.light
                  ? theme.primaryColor
                  : theme.primaryColorLight),
        ),
      );
    }

    SliverToBoxAdapter _buildMainContent() => SliverToBoxAdapter(
          child: Column(
            children: [
              buildDealImages(),
              buildDealDetails(),
              buildRateDeal(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Divider(),
              ),
              buildUserDetails(),
            ],
          ),
        );

    SliverPadding _buildCommentsHeader() => SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildCommentCounts(),
                    const SizedBox(width: 10),
                    buildPostCommentButton(),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        );

    SliverPadding _buildComments() => SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          sliver:
              DealComments(deal: _deal!, pagingController: _pagingController),
        );

    Widget _buildCustomScrollView() => CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildMainContent(),
            _buildCommentsHeader(),
            _buildComments(),
          ],
        );

    Widget _buildScrollToTopButton() => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              mini: true,
              child: const Icon(Icons.expand_less),
            ),
          ),
        );

    Widget _buildSeeDealButton() {
      Future<void> launchURL() async {
        await canLaunchUrl(Uri.parse(_deal!.dealUrl!))
            ? await launchUrl(Uri.parse(_deal!.dealUrl!))
            : throw Exception('Could not launch ${_deal!.dealUrl}');
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: launchURL,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(deviceWidth, 50),
            primary: theme.colorScheme.secondary,
          ),
          child: Text(l(context).seeDeal),
        ),
      );
    }

    Widget _buildBody() => Column(
          children: [
            if (_deal!.status == DealStatus.expired)
              const _DealIsExpiredBanner(),
            Expanded(
              child: Stack(
                children: [
                  _buildCustomScrollView(),
                  if (_showScrollToTopButton) _buildScrollToTopButton(),
                ],
              ),
            ),
            _buildSeeDealButton(),
          ],
        );

    Widget _buildError() => Scaffold(
          appBar: AppBar(),
          body: ErrorIndicatorUtil.buildFirstPageError(
            context,
            onTryAgain: () async {
              _dealFuture =
                  GetIt.I.get<APIRepository>().getDeal(dealId: widget.dealId);
              _commentCountFuture = GetIt.I
                  .get<APIRepository>()
                  .getDealCommentCount(dealId: widget.dealId);
              setState(() {});
            },
          ),
        );

    return FutureBuilder<dynamic>(
      future: Future.wait([_dealFuture, _commentCountFuture]),
      builder: (context, snapshot) {
        if (snapshot.data?[0] != null && snapshot.data?[1] != null) {
          _deal ??= snapshot.data[0]!;
          _commentCount ??= snapshot.data[1]!;
          // Prefetch and caches the images.
          if (_images == null) {
            _images = [_deal!.coverPhoto, ..._deal!.photos!];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              for (final image in _images!) {
                precacheImage(NetworkImage(image), context);
              }
            });
          }
          if (_user != null) {
            isUpvoted = _deal!.upvoters!.contains(_user!.id);
            isDownvoted = _deal!.downvoters!.contains(_user!.id);
          }
          _store ??= GetIt.I.get<Stores>().getStoreByStoreId(_deal!.store);

          return Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(),
          );
        } else if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return _buildError();
        }
      },
    );
  }
}

class _DealIsExpiredBanner extends StatefulWidget {
  const _DealIsExpiredBanner({Key? key}) : super(key: key);

  @override
  _DealIsExpiredBannerState createState() => _DealIsExpiredBannerState();
}

class _DealIsExpiredBannerState extends State<_DealIsExpiredBanner> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 30,
      child: ColoredBox(
        color: isDarkMode
            ? theme.primaryColorDark
            // ignore: deprecated_member_use
            : theme.colorScheme.secondaryVariant,
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
              l(context).thisDealHasExpired,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
