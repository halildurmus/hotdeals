import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../models/comment.dart';
import '../models/deal.dart';
import '../services/spring_service.dart';
import '../widgets/error_indicator.dart';
import 'comment_paged_sliver_list.dart';

class DealComments extends StatefulWidget {
  const DealComments({
    Key? key,
    required this.deal,
    required this.pagingController,
  }) : super(key: key);

  final Deal deal;
  final PagingController<int, Comment> pagingController;

  @override
  _DealCommentsState createState() => _DealCommentsState();
}

class _DealCommentsState extends State<DealComments> {
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

  @override
  Widget build(BuildContext context) {
    return CommentPagedListView(
      commentFuture: _commentFuture,
      noCommentsFound: buildNoCommentsFound(),
      pagingController: widget.pagingController,
    );
  }
}
