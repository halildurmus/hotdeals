import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:timeago/timeago.dart' as timeago;

import '../models/comment.dart';
import '../models/my_user.dart';
import '../services/spring_service.dart';
import '../settings/settings_controller.dart';
import '../utils/error_indicator_util.dart';
import 'user_profile_dialog.dart';

class CommentPagedListView extends StatefulWidget {
  const CommentPagedListView({
    Key? key,
    required this.commentFuture,
    required this.noCommentsFound,
    this.pageSize = 20,
    this.pagingController,
  }) : super(key: key);

  final Future<List<Comment>?> Function(int page, int size) commentFuture;
  final Widget noCommentsFound;
  final int pageSize;
  final PagingController<int, Comment>? pagingController;

  @override
  _CommentPagedListViewState createState() => _CommentPagedListViewState();
}

class _CommentPagedListViewState extends State<CommentPagedListView>
    with NetworkLoggy {
  late PagingController<int, Comment> _pagingController;

  @override
  void initState() {
    _pagingController = widget.pagingController ??
        PagingController<int, Comment>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.pagingController == null) {
      _pagingController.dispose();
    }
    super.dispose();
  }

  Future<void> _onUserTap(MyUser user) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => UserProfileDialog(user: user),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await widget.commentFuture(pageKey, widget.pageSize);
      final isLastPage = newItems!.length < widget.pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      loggy.error(error);
      _pagingController.error = error;
    }
  }

  Widget buildComment(Comment comment) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder<MyUser>(
                future: GetIt.I
                    .get<SpringService>()
                    .getUserById(id: comment.postedBy!),
                builder:
                    (BuildContext context, AsyncSnapshot<MyUser> snapshot) {
                  String avatar = 'http://www.gravatar.com/avatar';
                  String nickname = '...';

                  if (snapshot.hasData) {
                    avatar = snapshot.data!.avatar!;
                    nickname = snapshot.data!.nickname!;
                  } else if (snapshot.hasError) {
                    nickname = AppLocalizations.of(context)!.anErrorOccurred;
                  }

                  return GestureDetector(
                    onTap: () => _onUserTap(snapshot.data!),
                    child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: avatar,
                          imageBuilder: (BuildContext ctx,
                                  ImageProvider<Object> imageProvider) =>
                              CircleAvatar(
                                  backgroundImage: imageProvider, radius: 16),
                          placeholder: (BuildContext context, String url) =>
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
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView(
      pagingController: _pagingController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      builderDelegate: PagedChildBuilderDelegate<Comment>(
        animateTransitions: true,
        itemBuilder: (context, comment, index) => buildComment(comment),
        firstPageErrorIndicatorBuilder: (context) =>
            ErrorIndicatorUtil.buildFirstPageError(
          context,
          onTryAgain: () => _pagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) =>
            ErrorIndicatorUtil.buildNewPageError(
          context,
          onTryAgain: () => _pagingController.refresh(),
        ),
        noItemsFoundIndicatorBuilder: (context) => widget.noCommentsFound,
      ),
    );
  }
}
