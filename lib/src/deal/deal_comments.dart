import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../settings/settings_controller.dart';
import 'post_comment.dart';
import 'user_profile_dialog.dart';

class DealComments extends StatefulWidget {
  const DealComments({Key? key, required this.deal}) : super(key: key);

  final Deal deal;

  @override
  _DealCommentsState createState() => _DealCommentsState();
}

class _DealCommentsState extends State<DealComments> with UiLoggy {
  late Future<List<Comment>?> _commentsFuture;
  late MyUser? _user;

  @override
  void initState() {
    _commentsFuture = GetIt.I.get<SpringService>().getComments(widget.deal.id!);
    _user = context.read<UserControllerImpl>().user;
    super.initState();
  }

  Widget _buildNoComments() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            LineIcons.comments,
            color: theme.primaryColor,
            size: 100.0,
          ),
          const SizedBox(height: 16.0),
          Text(
            AppLocalizations.of(context)!.noComments,
            style: textTheme.headline6,
          ),
          const SizedBox(height: 10.0),
          Text(
            AppLocalizations.of(context)!.startTheConversation,
            style: textTheme.bodyText2!.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  // Widget buildPostCommentButton() {
  //   return Center(
  //     child: ElevatedButton(
  //       onPressed: () => postCommentOnTap(),
  //       child: Text(AppLocalizations.of(context)!.postAComment),
  //     ),
  //   );
  // }

  void onPostCommentTap() {
    if (_user == null) {
      loggy.warning('You need to log in!');
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
      setState(() {
        _commentsFuture =
            GetIt.I.get<SpringService>().getComments(widget.deal.id!);
      });
    });
  }

  Future<void> _onUserTap(MyUser user) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => UserProfileDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
                      AppLocalizations.of(context)!
                          .commentCount(comments.length),
                      style: textTheme.subtitle1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10.0),
                    TextButton(
                      onPressed: () => onPostCommentTap(),
                      child: Text(
                        AppLocalizations.of(context)!.postComment,
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
                                    .getUserById(id: comment.postedBy!),
                                builder: (BuildContext context,
                                    AsyncSnapshot<MyUser> snapshot) {
                                  String avatar =
                                      'http://www.gravatar.com/avatar';
                                  String nickname = '...';

                                  if (snapshot.hasData) {
                                    avatar = snapshot.data!.avatar!;
                                    nickname = snapshot.data!.nickname!;
                                  } else if (snapshot.hasError) {
                                    nickname = AppLocalizations.of(context)!
                                        .anErrorOccurred;
                                  }

                                  return GestureDetector(
                                    onTap: () => _onUserTap(snapshot.data!),
                                    child: Row(
                                      children: <Widget>[
                                        CachedNetworkImage(
                                          imageUrl: avatar,
                                          imageBuilder: (BuildContext ctx,
                                                  ImageProvider<Object>
                                                      imageProvider) =>
                                              CircleAvatar(
                                                  backgroundImage:
                                                      imageProvider,
                                                  radius: 16),
                                          placeholder: (BuildContext context,
                                                  String url) =>
                                              const CircleAvatar(radius: 16),
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
                                timeago.format(
                                  comment.createdAt!,
                                  locale:
                                      '${GetIt.I.get<SettingsController>().locale.languageCode}_short',
                                ),
                                style: textTheme.bodyText2!.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SelectableText(comment.message)
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
}
