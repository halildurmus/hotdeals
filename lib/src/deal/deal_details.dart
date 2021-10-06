import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../deal/user_profile_dialog.dart';
import '../models/categories.dart';
import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/store.dart';
import '../models/stores.dart';
import '../models/user_controller_impl.dart';
import '../models/vote_type.dart';
import '../services/spring_service.dart';
import '../utils/date_time_util.dart';
import '../utils/navigation_util.dart';
import '../widgets/deal_score_box.dart';
import '../widgets/expandable_text.dart';
import '../widgets/sign_in_dialog.dart';
import '../widgets/slider_indicator.dart';
import 'deal_comments.dart';
import 'image_fullscreen.dart';
import 'report_deal_dialog.dart';

enum _DealPopup { reportDeal }

class DealDetails extends StatefulWidget {
  const DealDetails({Key? key, required this.deal}) : super(key: key);

  final Deal deal;

  @override
  _DealDetailsState createState() => _DealDetailsState();
}

class _DealDetailsState extends State<DealDetails> {
  late Deal _deal;
  late Future<List<Comment>?> _commentsFuture;
  late List<String> _images;
  int currentIndex = 0;
  late Categories _categories;
  late Store _store;
  late MyUser? _user;
  bool isUpvoted = false;
  bool isDownvoted = false;
  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    _deal = widget.deal;
    _images = <String>[_deal.coverPhoto, ..._deal.photos!];
    // Prefetch and caches the images.
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      for (final String image in _images) {
        precacheImage(NetworkImage(image), context);
      }
    });
    _categories = GetIt.I.get<Categories>();
    final Stores stores = GetIt.I.get<Stores>();
    _store = stores.findByStoreId(_deal.store);
    _user = context.read<UserControllerImpl>().user;
    if (_user != null) {
      isUpvoted = _deal.upvoters!.contains(_user!.id);
      isDownvoted = _deal.downvoters!.contains(_user!.id);
      GetIt.I
          .get<SpringService>()
          .incrementViewsCounter(dealId: _deal.id!)
          .then((Deal? deal) {
        if (deal != null) {
          WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
            setState(() {
              _deal = deal;
            });
          });
        }
      });
    }
    _commentsFuture =
        GetIt.I.get<SpringService>().getComments(dealId: _deal.id!);
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 1000) {
            _showBackToTopButton = true;
          } else {
            _showBackToTopButton = false;
          }
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

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

    PreferredSizeWidget buildAppBar() {
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          centerTitle: true,
          title: Text(_deal.title),
          actions: <PopupMenuButton<_DealPopup>>[
            PopupMenuButton<_DealPopup>(
              icon: const Icon(
                FontAwesomeIcons.ellipsisV,
                size: 20.0,
              ),
              onSelected: (_DealPopup result) {
                if (result == _DealPopup.reportDeal) {
                  _onPressedReport();
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<_DealPopup>>[
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
        children: <Widget>[
          CarouselSlider(
            items: carouselItems,
            options: CarouselOptions(
              viewportFraction: 1.0,
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
              const SizedBox(height: 40, width: 40),
        ),
      );
    }

    Widget buildFavoriteButton() {
      return Consumer<UserControllerImpl>(
        builder: (BuildContext context, UserControllerImpl mongoUser,
            Widget? child) {
          final MyUser? user = mongoUser.user;
          final bool isFavorited = user?.favorites![widget.deal.id!] == true;

          return FloatingActionButton(
            heroTag: 'favoriteFAB',
            backgroundColor: theme.backgroundColor,
            elevation: 3,
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
                    Provider.of<UserControllerImpl>(context, listen: false)
                        .getUser();
                  }
                });
              } else {
                GetIt.I
                    .get<SpringService>()
                    .unfavoriteDeal(dealId: widget.deal.id!)
                    .then((bool result) {
                  if (result) {
                    Provider.of<UserControllerImpl>(context, listen: false)
                        .getUser();
                  }
                });
              }
            },
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
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                      children: <Widget>[
                        DealScoreBox(dealScore: _deal.dealScore!),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '•',
                            style: textTheme.bodyText2!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        FutureBuilder<List<Comment>?>(
                          future: _commentsFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Comment>?> snapshot) {
                            final List<Comment>? comments;

                            if (snapshot.hasData) {
                              comments = snapshot.data;
                            } else {
                              comments = [];
                            }

                            return Text(
                              AppLocalizations.of(context)!
                                  .commentCount(comments!.length),
                              style: textTheme.bodyText2!.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                      children: <Widget>[
                        Text(
                          r'$' + _deal.discountPrice.toStringAsFixed(0),
                          style: textTheme.headline5!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8.0),
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
          children: <Widget>[
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
                          .voteDeal(
                              dealId: _deal.id!, voteType: VoteType.upvote);

                      if (deal == null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalizations.of(context)!.anErrorOccurred),
                          ),
                        );
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
                          .voteDeal(
                              dealId: _deal.id!, voteType: VoteType.downvote);

                      if (deal == null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalizations.of(context)!.anErrorOccurred),
                          ),
                        );
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                children: <Widget>[
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
                    children: <Widget>[
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
                        style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? theme.primaryColor
                                : null),
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

    Widget buildComments() {
      return DealComments(deal: _deal);
    }

    Widget buildMainContent() {
      return Expanded(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildDealImages(),
                  buildDealDetails(),
                  buildRateDeal(),
                  const Padding(padding: EdgeInsets.all(16), child: Divider()),
                  buildUserDetails(),
                  buildComments(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (_showBackToTopButton)
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: _scrollToTop,
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
          ],
        ),
      );
    }

    Widget buildSeeDealButton() {
      Future<void> launchURL() async {
        await canLaunch(_deal.dealUrl)
            ? await launch(_deal.dealUrl)
            : throw 'Could not launch ${_deal.dealUrl}';
      }

      return Container(
        padding: const EdgeInsets.all(16),
        width: deviceWidth,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: launchURL,
            style: ElevatedButton.styleFrom(
              primary: theme.colorScheme.secondary,
            ),
            child: Text(AppLocalizations.of(context)!.seeDeal),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildMainContent(),
          buildSeeDealButton(),
        ],
      ),
    );
  }
}
