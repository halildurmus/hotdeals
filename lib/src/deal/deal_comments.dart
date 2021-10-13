import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
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
  int _commentsCount = 0;
  late MyUser? _user;
  late PagingController<int, Comment> _pagingController;

  @override
  void initState() {
    _user = context.read<UserController>().user;
    _pagingController = PagingController<int, Comment>(firstPageKey: 0);
    _updateCommentsCount();
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _updateCommentsCount() {
    GetIt.I
        .get<SpringService>()
        .getNumberOfCommentsByDealId(dealId: widget.deal.id!)
        .then((int? commentsCount) {
      if (commentsCount != null) {
        WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          _commentsCount = commentsCount;
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
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

  Future<List<Comment>?> _commentFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getComments(
            dealId: widget.deal.id!,
            page: page,
            size: size,
          );

  Widget buildNoCommentsFound() {
    return ErrorIndicator(
      icon: Icons.comment_outlined,
      title: AppLocalizations.of(context)!.noComments,
      message: AppLocalizations.of(context)!.startTheConversation,
    );
  }

  Widget buildCommentCounts() {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      AppLocalizations.of(context)!.commentCount(_commentsCount),
      style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
    );
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
