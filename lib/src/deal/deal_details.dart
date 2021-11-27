import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import '../services/spring_service.dart';
import '../utils/date_time_util.dart';
import '../utils/navigation_util.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/expandable_text.dart';
import '../widgets/sign_in_dialog.dart';
import '../widgets/slider_indicator.dart';
import '../widgets/user_profile_dialog.dart';
import 'deal_comments.dart';
import 'deal_score_box.dart';
import 'image_fullscreen.dart';
import 'post_comment.dart';
import 'report_deal_dialog.dart';

enum _DealPopup { reportDeal }

class DealDetails extends StatefulWidget {
  const DealDetails({Key? key, required this.deal}) : super(key: key);

  final Deal deal;

  @override
  _DealDetailsState createState() => _DealDetailsState();
}

class _DealDetailsState extends State<DealDetails> {
  final _pagingController = PagingController<int, Comment>(firstPageKey: 0);
  late Deal _deal;
  late List<String> _images;
  int currentIndex = 0;
  late Categories _categories;
  late Store _store;
  late MyUser? _user;
  int _commentsCount = 0;
  bool isUpvoted = false;
  bool isDownvoted = false;
  bool _showScrollToTopButton = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    _deal = widget.deal;
    _updateCommentsCount();
    _images = [_deal.coverPhoto, ..._deal.photos!];
    // Prefetch and caches the images.
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      for (final String image in _images) {
        precacheImage(NetworkImage(image), context);
      }
    });
    _categories = GetIt.I.get<Categories>();
    final Stores stores = GetIt.I.get<Stores>();
    _store = stores.getStoreByStoreId(_deal.store);
    _user = context.read<UserController>().user;
    if (_user != null) {
      isUpvoted = _deal.upvoters!.contains(_user!.id);
      isDownvoted = _deal.downvoters!.contains(_user!.id);
      _fetchDeal();
    }
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showScrollToTopButton = _scrollController.offset >= 1000;
        });
      });
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

  void _fetchDeal() {
    GetIt.I.get<SpringService>().getDeal(dealId: _deal.id!).then((Deal? deal) {
      if (deal != null) {
        WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          if (mounted) {
            setState(() {
              _deal = deal;
            });
          }
        });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    final List<Widget> carouselItems = _images.map((String item) {
      return GestureDetector(
        onTap: () => NavigationUtil.navigate(
          context,
          ImageFullScreen(images: _images, currentIndex: currentIndex),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            color: theme.brightness == Brightness.dark ? Colors.white : null,
          ),
          padding: theme.brightness == Brightness.dark
              ? const EdgeInsets.all(2)
              : null,
          child: Hero(
            tag: _deal.id!,
            child: Image.network(item, fit: BoxFit.cover),
          ),
        ),
      );
    }).toList();

    Future<void> _onPressedReport() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
            ReportDealDialog(reportedDealId: _deal.id!),
      );
    }

    PreferredSizeWidget _buildAppBar() {
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          centerTitle: true,
          title: Text(_deal.title),
          actions: [
            // TODO(halildurmus): Hide "Report Deal" button to the poster of the deal
            PopupMenuButton<_DealPopup>(
              icon: const Icon(Icons.more_vert),
              onSelected: (_DealPopup result) {
                if (result == _DealPopup.reportDeal) {
                  _onPressedReport();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<_DealPopup>(
                  value: _DealPopup.reportDeal,
                  child: Text(AppLocalizations.of(context)!.reportDeal),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildDealImages() {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            items: carouselItems,
            options: CarouselOptions(
              viewportFraction: 1,
              height: deviceHeight / 2,
              enlargeCenterPage: true,
              onPageChanged: (int i, CarouselPageChangedReason reason) {
                setState(() {
                  currentIndex = i;
                });
              },
            ),
          ),
          if (_images.length > 1)
            SliderIndicator(images: _images, currentIndex: currentIndex)
        ],
      );
    }

    Widget buildDealDescription() {
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        child: ExpandableText(text: _deal.description),
      );
    }

    Widget buildStoreImage() {
      return Container(
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
          imageUrl: _store.logo,
          imageBuilder:
              (BuildContext ctx, ImageProvider<Object> imageProvider) {
            return DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider),
              ),
            );
          },
          placeholder: (BuildContext context, String url) =>
              const SizedBox.square(dimension: 40),
        ),
      );
    }

    Widget buildFavoriteButton() {
      return Consumer<UserController>(
        builder:
            (BuildContext context, UserController mongoUser, Widget? child) {
          final MyUser? user = mongoUser.user;
          final bool isFavorited = user?.favorites![widget.deal.id!] == true;

          return FloatingActionButton(
            onPressed: () {
              if (_user == null) {
                GetIt.I.get<SignInDialog>().showSignInDialog(context);

                return;
              }

              if (!isFavorited) {
                GetIt.I
                    .get<SpringService>()
                    .favoriteDeal(dealId: widget.deal.id!)
                    .then((bool result) {
                  if (result) {
                    Provider.of<UserController>(context, listen: false)
                        .getUser();
                  }
                });
              } else {
                GetIt.I
                    .get<SpringService>()
                    .unfavoriteDeal(dealId: widget.deal.id!)
                    .then((bool result) {
                  if (result) {
                    Provider.of<UserController>(context, listen: false)
                        .getUser();
                  }
                });
              }
            },
            heroTag: 'favoriteFAB',
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
    }

    Widget buildDealDetails() {
      return Column(
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
                      DateTimeUtil.formatDateTime(_deal.createdAt!,
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
                        DealScoreBox(score: _deal.dealScore!),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context)!.dealScore,
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
                            '•',
                            style: textTheme.bodyText2!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .commentCount(_commentsCount),
                          style: textTheme.bodyText2!.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '•',
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
                          _deal.views.toString(),
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
                        _deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headline6!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _categories.getCategoryNameFromCategory(
                        category: _deal.category,
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
                          r'$' + _deal.discountPrice.toStringAsFixed(0),
                          style: textTheme.headline5!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          r'$' + _deal.price.toStringAsFixed(0),
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
    }

    Widget buildRateDeal() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.didYouLikeTheDeal,
              style: textTheme.bodyText2!.copyWith(
                color: theme.brightness == Brightness.light
                    ? Colors.black54
                    : Colors.grey,
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: isUpvoted
                  ? null
                  : () async {
                      if (_user == null) {
                        GetIt.I.get<SignInDialog>().showSignInDialog(context);

                        return;
                      }

                      final Deal? deal = await GetIt.I
                          .get<SpringService>()
                          .upvoteDeal(dealId: _deal.id!);

                      if (deal == null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        final snackBar = CustomSnackBar(
                          icon: const Icon(FontAwesomeIcons.exclamationCircle,
                              size: 20),
                          text: AppLocalizations.of(context)!.anErrorOccurred,
                        ).buildSnackBar(context);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          _deal = deal;
                          isUpvoted = true;
                          isDownvoted = false;
                        });
                      }
                    },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isUpvoted ? Colors.green : Colors.transparent,
                      width: 1.5),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  color: theme.brightness == Brightness.light
                      ? Colors.grey.shade300 //theme.primaryColor
                      : theme.primaryColor.withOpacity(.5),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(FontAwesomeIcons.solidThumbsUp,
                    color: isUpvoted ? Colors.green : Colors.grey, size: 16),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: isDownvoted
                  ? null
                  : () async {
                      if (_user == null) {
                        GetIt.I.get<SignInDialog>().showSignInDialog(context);

                        return;
                      }

                      final Deal? deal = await GetIt.I
                          .get<SpringService>()
                          .downvoteDeal(dealId: _deal.id!);
                      if (deal == null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        final snackBar = CustomSnackBar(
                          icon: const Icon(FontAwesomeIcons.exclamationCircle,
                              size: 20),
                          text: AppLocalizations.of(context)!.anErrorOccurred,
                        ).buildSnackBar(context);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          _deal = deal;
                          isDownvoted = true;
                          isUpvoted = false;
                        });
                      }
                    },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isDownvoted
                          ? Colors.pinkAccent.shade100
                          : Colors.transparent,
                      width: 1.5),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  color: theme.brightness == Brightness.light
                      ? Colors.grey.shade300 //theme.primaryColor
                      : theme.primaryColor.withOpacity(.5),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(FontAwesomeIcons.solidThumbsDown,
                    color:
                        isDownvoted ? Colors.pinkAccent.shade100 : Colors.grey,
                    size: 16),
              ),
            ),
          ],
        ),
      );
    }

    Future<void> _onUserTap(String userId) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) => UserProfileDialog(userId: userId),
      );
    }

    Widget buildUserDetails() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FutureBuilder<MyUser>(
          future: GetIt.I.get<SpringService>().getUserById(id: _deal.postedBy!),
          builder: (BuildContext context, AsyncSnapshot<MyUser> snapshot) {
            String avatar = 'http://www.gravatar.com/avatar';
            String nickname = '...';
            VoidCallback? onTap;

            if (snapshot.hasData) {
              onTap = () => _onUserTap(snapshot.data!.id!);
              avatar = snapshot.data!.avatar!;
              nickname = snapshot.data!.nickname!;
            } else if (snapshot.hasError) {
              nickname = AppLocalizations.of(context)!.anErrorOccurred;
            }

            return GestureDetector(
              onTap: _user == null
                  ? () => GetIt.I.get<SignInDialog>().showSignInDialog(context)
                  : onTap,
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: avatar,
                    imageBuilder: (BuildContext ctx,
                            ImageProvider<Object> imageProvider) =>
                        CircleAvatar(backgroundImage: imageProvider),
                    placeholder: (BuildContext context, String url) =>
                        const CircleAvatar(),
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
                            horizontal: 3, vertical: 1),
                        child: Text(
                          AppLocalizations.of(context)!.originalPoster,
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
    }

    Widget buildCommentCounts() {
      final textTheme = Theme.of(context).textTheme;

      return Text(
        AppLocalizations.of(context)!.commentCount(_commentsCount),
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
        builder: (BuildContext context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: PostComment(deal: widget.deal),
          );
        },
      ).then((_) {
        _updateCommentsCount();
        _pagingController.refresh();
      });
    }

    Widget buildPostCommentButton() {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;

      return TextButton(
        onPressed: () => _onPostCommentTap(),
        child: Text(
          AppLocalizations.of(context)!.postComment,
          style: textTheme.subtitle2!.copyWith(
              color: theme.brightness == Brightness.light
                  ? theme.primaryColor
                  : theme.primaryColorLight),
        ),
      );
    }

    SliverToBoxAdapter _buildMainContent() {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            buildDealImages(),
            buildDealDetails(),
            buildRateDeal(),
            const Padding(padding: EdgeInsets.all(16), child: Divider()),
            buildUserDetails(),
          ],
        ),
      );
    }

    SliverPadding _buildCommentsHeader() {
      return SliverPadding(
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
    }

    SliverPadding _buildComments() {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        sliver: DealComments(deal: _deal, pagingController: _pagingController),
      );
    }

    Widget _buildCustomScrollView() {
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildMainContent(),
          _buildCommentsHeader(),
          _buildComments(),
        ],
      );
    }

    Widget _buildScrollToTopButton() {
      return Padding(
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
    }

    Widget _buildSeeDealButton() {
      Future<void> launchURL() async {
        await canLaunch(_deal.dealUrl)
            ? await launch(_deal.dealUrl)
            : throw 'Could not launch ${_deal.dealUrl}';
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: launchURL,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(deviceWidth, 50),
            primary: theme.colorScheme.secondary,
          ),
          child: Text(AppLocalizations.of(context)!.seeDeal),
        ),
      );
    }

    Widget _buildBody() {
      return Column(
        children: [
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
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
}
