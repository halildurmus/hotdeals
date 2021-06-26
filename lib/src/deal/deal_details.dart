import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../deal/post_comment.dart';
import '../deal/user_profile.dart';
import '../models/categories.dart';
import '../models/comment.dart';
import '../models/deal.dart';
import '../models/user_controller_impl.dart';
import '../models/my_user.dart';
import '../models/report.dart';
import '../models/store.dart';
import '../models/stores.dart';
import '../models/vote_type.dart';
import '../services/spring_service.dart';
import '../utils/navigation_util.dart';
import '../widgets/deal_score_box.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/slider_indicator.dart';
import 'image_fullscreen.dart';

enum _DealPopup { reportDeal }

class DealDetails extends StatefulWidget {
  const DealDetails({Key? key, required this.deal}) : super(key: key);

  final Deal deal;

  @override
  _DealDetailsState createState() => _DealDetailsState();
}

class _DealDetailsState extends State<DealDetails> {
  late Deal _deal;
  late List<String> _images;
  int currentIndex = 0;
  late Categories _categories;
  late Store _store;
  late MyUser? _user;
  late Future<List<Comment>?> _commentsFuture;
  bool isUpVoted = false;
  bool isDownVoted = false;
  bool repostCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;
  late TextEditingController messageController;

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
      isUpVoted = _deal.upVoters!.contains(_user!.id);
      isDownVoted = _deal.downVoters!.contains(_user!.id);
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

    _commentsFuture = GetIt.I.get<SpringService>().getComments(_deal.id!);
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
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

    Future<void> sendReport() async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final Report report = Report(
        reportedBy: _user!.id!,
        reportedDeal: _deal.id,
        reasons: <String>[
          if (repostCheckbox) 'Repost',
          if (spamCheckbox) 'Spam',
          if (otherCheckbox) 'Other'
        ],
        message:
            messageController.text.isNotEmpty ? messageController.text : null,
      );

      final Report? sentReport =
          await GetIt.I.get<SpringService>().sendReport(report: report);
      print(sentReport);

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (sentReport != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reported Deal')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred!'),
          ),
        );
      }
    }

    PreferredSizeWidget buildAppBar() {
      return PreferredSize(
        preferredSize: const Size.fromHeight(55),
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
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Report Deal',
                                    style: textTheme.headline6,
                                  ),
                                  const SizedBox(height: 10),
                                  CheckboxListTile(
                                    title: const Text('Repost'),
                                    value: repostCheckbox,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        repostCheckbox = newValue!;
                                      });
                                    },
                                  ),
                                  CheckboxListTile(
                                    title: const Text('Spam'),
                                    value: spamCheckbox,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        spamCheckbox = newValue!;
                                      });
                                    },
                                  ),
                                  CheckboxListTile(
                                    title: const Text('Other'),
                                    value: otherCheckbox,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        otherCheckbox = newValue!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: messageController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintStyle: textTheme.bodyText2!.copyWith(
                                          color: theme.brightness ==
                                                  Brightness.light
                                              ? Colors.black54
                                              : Colors.grey),
                                      hintText:
                                          'Enter some details about your report here...',
                                    ),
                                    minLines: 1,
                                    maxLines: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    width: deviceWidth,
                                    child: SizedBox(
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: repostCheckbox ||
                                                spamCheckbox ||
                                                otherCheckbox
                                            ? sendReport
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          primary: theme.colorScheme.secondary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: const Text('Report Deal'),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<_DealPopup>>[
                const PopupMenuItem<_DealPopup>(
                  value: _DealPopup.reportDeal,
                  child: Text('Report Deal'),
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
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        child: Text(
          _deal.description,
          style: textTheme.bodyText2!.copyWith(
            color: theme.brightness == Brightness.dark ? Colors.grey : null,
            fontSize: 15,
          ),
        ),
      );
    }

    Widget buildStoreImage() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: theme.brightness == Brightness.dark ? Colors.white : null,
        ),
        padding: theme.brightness == Brightness.dark
            ? const EdgeInsets.all(4)
            : null,
        child: Image.network(
          _store.logo,
          height: 40,
          width: 40,
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
            backgroundColor: theme.backgroundColor,
            elevation: 3,
            onPressed: () {
              if (_user == null) {
                print('You need to log in!');

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
                  } else {
                    print(
                        'An error occurred while adding this deal to your favorites.');
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
                  } else {
                    print(
                        'An error occurred while removing this deal from your favorites.');
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
                      timeago.format(_deal.createdAt!),
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
                          'Fırsat Puanı',
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
                              comments = snapshot.data!;
                            } else {
                              comments = <Comment>[];
                            }

                            return Text(
                              '${comments.length} yorum',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _deal.title,
                      style: textTheme.headline6!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _categories.getCategoryName(category: _deal.category),
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
              'Fırsatı beğendiniz mi?',
              style: textTheme.bodyText2!.copyWith(
                color: theme.brightness == Brightness.light
                    ? Colors.black54
                    : Colors.grey,
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () async {
                if (_user == null) {
                  print('You need to log in!');
                  return;
                }

                final Deal? deal = await GetIt.I
                    .get<SpringService>()
                    .voteDeal(dealId: _deal.id!, voteType: VoteType.upVote);

                setState(() {
                  if (deal != null) {
                    _deal = deal;
                  }

                  isUpVoted = true;
                  isDownVoted = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isUpVoted ? Colors.green : Colors.transparent,
                      width: 1.5),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  color: theme.brightness == Brightness.light
                      ? Colors.grey.shade300 //theme.primaryColor
                      : theme.primaryColor.withOpacity(.5),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(FontAwesomeIcons.solidThumbsUp,
                    color: isUpVoted ? Colors.green : Colors.grey, size: 16),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () async {
                if (_user == null) {
                  print('You need to log in!');
                  return;
                }

                final Deal? deal = await GetIt.I
                    .get<SpringService>()
                    .voteDeal(dealId: _deal.id!, voteType: VoteType.downVote);

                setState(() {
                  if (deal != null) {
                    _deal = deal;
                  }

                  isDownVoted = true;
                  isUpVoted = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isDownVoted
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
                        isDownVoted ? Colors.pinkAccent.shade100 : Colors.grey,
                    size: 16),
              ),
            ),
          ],
        ),
      );
    }

    void _userOnTap(MyUser user) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: UserProfile(user: user),
          );
        },
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
            void Function()? onTap;

            if (snapshot.hasData) {
              onTap = () => _userOnTap(snapshot.data!);
              avatar = snapshot.data!.avatar!;
              nickname = snapshot.data!.nickname!;
            } else if (snapshot.hasError) {
              print(snapshot.error.toString());
              nickname = 'An error occurred';
            }

            return GestureDetector(
              onTap: onTap,
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
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
                          'PAYLAŞAN KULLANICI',
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

    void postCommentOnTap() {
      if (_user == null) {
        print('You need to log in!');
        return;
      }

      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: PostComment(deal: _deal),
          );
        },
      ).then((dynamic value) {
        setState(() {
          _commentsFuture = GetIt.I.get<SpringService>().getComments(_deal.id!);
        });
      });
    }

    Widget _buildNoComments() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: <Widget>[
            Icon(
              LineIcons.comments,
              color: theme.primaryColor,
              size: 100.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No comments yet',
              style: textTheme.headline6,
            ),
            const SizedBox(height: 10.0),
            Text(
              'Start the conversation',
              style: textTheme.bodyText2!.copyWith(fontSize: 15),
            ),
          ],
        ),
      );
    }

    Widget buildComments() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Comment>?>(
          future: _commentsFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<Comment>?> snapshot) {
            if (snapshot.hasData) {
              final List<Comment> comments = snapshot.data!;

              if (comments.isEmpty) {
                return _buildNoComments();
              }

              return Column(
                children: <Widget>[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${comments.length} Yorum',
                        style: textTheme.subtitle1!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10.0),
                      TextButton(
                        onPressed: () {
                          postCommentOnTap();
                        },
                        child: Text(
                          'Yorum Paylaş',
                          style: textTheme.subtitle2!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? theme.primaryColor
                                  : theme.primaryColorLight),
                        ),
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Comment comment = comments.elementAt(index);

                      return Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: theme.brightness == Brightness.light
                              ? Colors.grey.shade200
                              : Colors.black26,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FutureBuilder<MyUser>(
                                  future: GetIt.I
                                      .get<SpringService>()
                                      .getUserById(id: comment.postedBy),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<MyUser> snapshot) {
                                    String avatar =
                                        'http://www.gravatar.com/avatar';
                                    String nickname = '...';

                                    if (snapshot.hasData) {
                                      avatar = snapshot.data!.avatar!;
                                      nickname = snapshot.data!.nickname!;
                                    } else if (snapshot.hasError) {
                                      print(snapshot.error.toString());
                                      nickname = 'An error occurred';
                                    }

                                    return GestureDetector(
                                      onTap: () => _userOnTap(snapshot.data!),
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(avatar),
                                            radius: 16,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            nickname,
                                            style: textTheme.subtitle2,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  timeago.format(comment.createdAt!,
                                      locale: 'en'),
                                  style: textTheme.bodyText2!.copyWith(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(comment.message)
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 10);
                    },
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);

              return Text(snapshot.error.toString());
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    }

    Widget buildPostCommentButton() {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            postCommentOnTap();
          },
          child: const Text('Bir Yorum Paylaş'),
        ),
      );
    }

    Widget buildMainContent() {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildDealImages(),
              buildDealDetails(),
              buildRateDeal(),
              const Padding(padding: EdgeInsets.all(16), child: Divider()),
              buildUserDetails(),
              buildComments(),
              buildPostCommentButton(),
              const SizedBox(height: 20),
            ],
          ),
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
            child: const Text('See Deal'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: <Widget>[
          buildMainContent(),
          buildSeeDealButton(),
        ],
      ),
    );
  }
}
