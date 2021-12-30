import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../models/comment.dart';
import '../models/comments.dart';
import '../utils/error_indicator_util.dart';
import 'comment_item.dart';

class CommentPagedListView extends StatefulWidget {
  const CommentPagedListView({
    Key? key,
    required this.commentFuture,
    required this.noCommentsFound,
    this.pageSize = 8,
    this.pagingController,
  }) : super(key: key);

  final Future<Comments?> Function(int page, int size) commentFuture;
  final Widget noCommentsFound;
  final int pageSize;
  final PagingController<int, Comment>? pagingController;

  @override
  _CommentPagedListViewState createState() => _CommentPagedListViewState();
}

class _CommentPagedListViewState extends State<CommentPagedListView>
    with NetworkLoggy {
  late final PagingController<int, Comment> _pagingController;

  @override
  void initState() {
    _pagingController = widget.pagingController ??
        PagingController<int, Comment>(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.pagingController == null) {
      _pagingController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final comments = await widget.commentFuture(pageKey, widget.pageSize);
      final newItems = comments?.comments;
      final isLastPage = newItems!.length < widget.pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } on Exception catch (error) {
      loggy.error(error);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => PagedSliverList.separated(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Comment>(
          animateTransitions: true,
          itemBuilder: (context, comment, index) =>
              CommentItem(comment: comment),
          firstPageErrorIndicatorBuilder: (context) =>
              ErrorIndicatorUtil.buildFirstPageError(
            context,
            onTryAgain: _pagingController.refresh,
          ),
          newPageErrorIndicatorBuilder: (context) =>
              ErrorIndicatorUtil.buildNewPageError(
            context,
            onTryAgain: _pagingController.refresh,
          ),
          noItemsFoundIndicatorBuilder: (context) => widget.noCommentsFound,
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      );
}
