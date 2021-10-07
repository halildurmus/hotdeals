import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/error_indicator.dart';
import '../widgets/sign_in_dialog.dart';
import 'comment_paged_listview.dart';
import 'post_comment.dart';

class DealComments extends StatefulWidget {
  const DealComments({Key? key, required this.deal}) : super(key: key);

  final Deal deal;

  @override
  _DealCommentsState createState() => _DealCommentsState();
}

class _DealCommentsState extends State<DealComments> {
  int commentsCount = -1;
  late MyUser? _user;
  late PagingController<int, Comment> _pagingController;

  @override
  void initState() {
    _user = context.read<UserControllerImpl>().user;
    _pagingController = PagingController<int, Comment>(firstPageKey: 0);
    updateCommentsCount();
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void updateCommentsCount() {
    GetIt.I
        .get<SpringService>()
        .getComments(dealId: widget.deal.id!)
        .then((List<Comment>? comments) {
      if (comments != null) {
        WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          setState(() {
            commentsCount = comments.length;
          });
        });
      }
    });
  }

  void onPostCommentTap() {
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
      updateCommentsCount();
      _pagingController.refresh();
    });
  }

  Future<List<Comment>?> _commentFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getComments(
            dealId: widget.deal.id!,
            page: page,
            size: size,
          );

  Widget buildNoCommentsFound() {
    return ErrorIndicator(
      icon: LineIcons.comments,
      title: AppLocalizations.of(context)!.noComments,
      message: AppLocalizations.of(context)!.startTheConversation,
    );
  }

  Widget buildCommentCounts() {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      AppLocalizations.of(context)!.commentCount(commentsCount),
      style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget buildPostCommentButton() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TextButton(
      onPressed: () => onPostCommentTap(),
      child: Text(
        AppLocalizations.of(context)!.postComment,
        style: textTheme.subtitle2!.copyWith(
            color: theme.brightness == Brightness.light
                ? theme.primaryColor
                : theme.primaryColorLight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 10),
          CommentPagedListView(
            commentFuture: _commentFuture,
            noCommentsFound: buildNoCommentsFound(),
            pagingController: _pagingController,
          )
        ],
      ),
    );
  }
}
