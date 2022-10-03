import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../../../../../common_widgets/error_indicator.dart';
import '../../../domain/comment.dart';
import 'comment_item.dart';

class CommentPagedListView extends StatefulWidget {
  const CommentPagedListView({
    required this.commentFuture,
    required this.noCommentsFound,
    super.key,
    this.pageSize = 8,
    this.pagingController,
  });

  final Future<Comments?> Function(int page, int size) commentFuture;
  final Widget noCommentsFound;
  final int pageSize;
  final PagingController<int, Comment>? pagingController;

  @override
  State<CommentPagedListView> createState() => _CommentPagedListViewState();
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
      if (mounted) {
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
    } on Exception catch (error) {
      loggy.error(error);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedSliverList.separated(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Comment>(
        animateTransitions: true,
        itemBuilder: (_, comment, __) => CommentItem(comment: comment),
        firstPageErrorIndicatorBuilder: (_) => NoConnectionError(
          onPressed: _pagingController.refresh,
        ),
        firstPageProgressIndicatorBuilder: (_) => const CommentItemShimmer(),
        newPageErrorIndicatorBuilder: (_) => SomethingWentWrongError(
          onPressed: _pagingController.refresh,
        ),
        newPageProgressIndicatorBuilder: (_) => const CommentItemShimmer(),
        noItemsFoundIndicatorBuilder: (_) => widget.noCommentsFound,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 5),
    );
  }
}
