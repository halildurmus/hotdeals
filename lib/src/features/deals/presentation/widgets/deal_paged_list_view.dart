import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../../../../common_widgets/custom_alert_dialog.dart';
import '../../../../common_widgets/custom_snack_bar.dart';
import '../../../../common_widgets/error_indicator.dart';
import '../../../../common_widgets/filter_bar.dart';
import '../../../../core/firebase_storage_service.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../auth/domain/my_user.dart';
import '../../../auth/presentation/user_controller.dart';
import '../../../search/domain/search_params.dart';
import '../../../search/domain/search_response.dart';
import '../../domain/deal.dart';
import 'deal_item.dart';

class DealPagedListView extends ConsumerStatefulWidget {
  const DealPagedListView({
    required this.noDealsFound,
    super.key,
    this.dealsFuture,
    this.pageSize = 20,
    this.pagingController,
    this.removeDealWhenUnfavorited = false,
    this.searchParams,
    this.searchResultsFuture,
    this.showFilterBar = false,
    this.useRefreshIndicator = true,
  });

  const DealPagedListView.withFilterBar({
    required this.noDealsFound,
    required this.searchParams,
    required this.searchResultsFuture,
    super.key,
    this.dealsFuture,
    this.pageSize = 20,
    this.pagingController,
    this.removeDealWhenUnfavorited = false,
    this.showFilterBar = true,
    this.useRefreshIndicator = false,
  });

  final Future<List<Deal>> Function(int page, int size)? dealsFuture;
  final Widget noDealsFound;
  final int pageSize;
  final PagingController<int, Deal>? pagingController;
  final bool removeDealWhenUnfavorited;
  final SearchParams? searchParams;
  final Future<SearchResponse> Function(int page, int size)?
      searchResultsFuture;
  final bool showFilterBar;
  final bool useRefreshIndicator;

  @override
  ConsumerState<DealPagedListView> createState() => _DealPagedListViewState();
}

class _DealPagedListViewState extends ConsumerState<DealPagedListView>
    with NetworkLoggy {
  late final PagingController<int, Deal> _pagingController;
  PagingStatus? _pagingStatus;
  SearchResponse? _searchResponse;

  @override
  void initState() {
    _pagingController =
        widget.pagingController ?? PagingController<int, Deal>(firstPageKey: 0);
    _pagingController
      ..addStatusListener((status) {
        if (mounted) {
          setState(() => _pagingStatus = status);
        }
      })
      ..addPageRequestListener(_fetchPage);
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
      late final List<Deal> newItems;
      if (widget.dealsFuture != null) {
        newItems = await widget.dealsFuture!(pageKey, widget.pageSize);
      } else {
        _searchResponse =
            await widget.searchResultsFuture!(pageKey, widget.pageSize);
        newItems = _searchResponse!.hits.hits;
      }
      if (mounted) {
        final isLastPage = newItems.length < widget.pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
    } on Exception catch (e) {
      loggy.error(e, e);
      _pagingController.error = e;
    }
  }

  void onFavoriteButtonPressed(MyUser? user, String dealId, bool isFavorited) {
    if (!isFavorited) {
      ref
          .read(hotdealsRepositoryProvider)
          .favoriteDeal(dealId: dealId)
          .then((result) {
        if (result) {
          ref.read(userProvider.notifier).refreshUser();
        } else {
          CustomSnackBar.error(text: context.l.favoriteDealError)
              .showSnackBar(context);
        }
      });
    } else {
      ref
          .read(hotdealsRepositoryProvider)
          .unfavoriteDeal(dealId: dealId)
          .then((result) {
        if (result) {
          ref.read(userProvider.notifier).refreshUser();
          if (widget.removeDealWhenUnfavorited) {
            _pagingController.itemList?.removeWhere((e) => e.id == dealId);
          }
        } else {
          CustomSnackBar.error(text: context.l.unfavoriteDealError)
              .showSnackBar(context);
        }
      });
    }
  }

  Future<void> onDeleteButtonPressed(MyUser? user, Deal deal) async {
    await CustomAlertDialog(
      title: context.l.deleteConfirm,
      cancelActionText: context.l.cancel,
      defaultAction: () async {
        final isDealDeleted = await ref
            .read(hotdealsRepositoryProvider)
            .deleteDeal(dealId: deal.id!);
        if (isDealDeleted) {
          // Deletes the deal images.
          await ref
              .read(firebaseStorageServiceProvider)
              .deleteImagesFromUrl([deal.coverPhoto, ...deal.photos!]);
          _pagingController.refresh();
        } else {
          if (!mounted) return;
          CustomSnackBar.error(text: context.l.deleteDealError)
              .showSnackBar(context);
        }
      },
      defaultActionText: context.l.delete,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final searchHitsIsNotEmpty = _searchResponse?.hits.docCount != 0;
    final itemListIsEmpty = _pagingController.itemList?.isEmpty ?? false;
    final shouldShowFilterBar = widget.showFilterBar && _pagingStatus != null;
    final shouldShowTryAgainButton = shouldShowFilterBar &&
        widget.searchParams?.filterCount != 0 &&
        itemListIsEmpty;

    Widget buildPagedListView() {
      return PagedListView(
        pagingController: _pagingController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        builderDelegate: PagedChildBuilderDelegate<Deal>(
          animateTransitions: true,
          itemBuilder: (context, deal, index) {
            final isFavorited = user?.favorites!.contains(deal.id!) ?? false;
            return DealItem(
              deal: deal,
              index: index,
              isFavorited: isFavorited,
              onEditButtonPressed: () =>
                  context.go('/update-deal', extra: deal),
              onFavoriteButtonPressed: () =>
                  onFavoriteButtonPressed(user, deal.id!, isFavorited),
              onDeleteButtonPressed: () => onDeleteButtonPressed(user, deal),
              pagingController: _pagingController,
              showControlButtons: user != null && (deal.postedBy! == user.id!),
            );
          },
          firstPageErrorIndicatorBuilder: (context) => NoConnectionError(
            onPressed: _pagingController.refresh,
          ),
          newPageErrorIndicatorBuilder: (context) => SomethingWentWrongError(
            onPressed: _pagingController.refresh,
          ),
          noItemsFoundIndicatorBuilder: (context) => widget.noDealsFound,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: shouldShowTryAgainButton
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (shouldShowFilterBar && searchHitsIsNotEmpty)
          FilterBar(
            pagingController: _pagingController,
            searchParams: widget.searchParams!,
            searchResponse: _searchResponse,
          )
        else if (shouldShowTryAgainButton)
          ErrorIndicator(
            icon: Icons.local_offer,
            title: context.l.couldNotFindAnyDeal,
            tryAgainText: context.l.resetFilters,
            onTryAgain: () {
              widget.searchParams!.reset();
              _pagingController.refresh();
            },
          ),
        if (!shouldShowTryAgainButton && !widget.useRefreshIndicator)
          Expanded(child: buildPagedListView())
        else if (!shouldShowTryAgainButton)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(_pagingController.refresh),
              child: buildPagedListView(),
            ),
          )
      ],
    );
  }
}
