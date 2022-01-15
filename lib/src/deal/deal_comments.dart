import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../models/comment.dart';
import '../models/comments.dart';
import '../models/deal.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/error_indicator.dart';
import 'comment_paged_sliver_list.dart';

class DealComments extends StatefulWidget {
  const DealComments({
    required this.deal,
    required this.pagingController,
    Key? key,
  }) : super(key: key);

  final Deal deal;
  final PagingController<int, Comment> pagingController;

  @override
  _DealCommentsState createState() => _DealCommentsState();
}

class _DealCommentsState extends State<DealComments> {
  Future<Comments?> _commentFuture(int page, int size) =>
      GetIt.I.get<APIRepository>().getDealComments(
            dealId: widget.deal.id!,
            page: page,
            size: size,
          );

  Widget buildNoCommentsFound() => ErrorIndicator(
        icon: Icons.comment_outlined,
        title: l(context).noComments,
        message: l(context).startTheConversation,
      );

  @override
  Widget build(BuildContext context) => CommentPagedListView(
        commentFuture: _commentFuture,
        noCommentsFound: buildNoCommentsFound(),
        pagingController: widget.pagingController,
      );
}
