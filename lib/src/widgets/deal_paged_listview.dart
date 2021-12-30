import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:provider/provider.dart';

import '../deal/update_deal.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../search/search_params.dart';
import '../search/search_response.dart';
import '../services/firebase_storage_service.dart';
import '../services/spring_service.dart';
import '../utils/error_indicator_util.dart';
import '../utils/localization_util.dart';
import '../utils/navigation_util.dart';
import '../widgets/deal_item.dart';
import '../widgets/sign_in_dialog.dart';
import 'custom_alert_dialog.dart';
import 'custom_snackbar.dart';
import 'error_indicator.dart';
import 'filter_bar.dart';

class DealPagedListView extends StatefulWidget {
  const DealPagedListView({
    Key? key,
    this.dealsFuture,
    required this.noDealsFound,
    this.pageSize = 20,
    this.pagingController,
    this.removeDealWhenUnfavorited = false,
    this.searchParams,
    this.searchResultsFuture,
    this.showFilterBar = false,
    this.useRefreshIndicator = true,
  }) : super(key: key);

  const DealPagedListView.withFilterBar({
    Key? key,
    this.dealsFuture,
    required this.noDealsFound,
    this.pageSize = 20,
    this.pagingController,
    this.removeDealWhenUnfavorited = false,
    required this.searchParams,
    required this.searchResultsFuture,
    this.showFilterBar = true,
    this.useRefreshIndicator = false,
  }) : super(key: key);

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
  _DealPagedListViewState createState() => _DealPagedListViewState();
}

class _DealPagedListViewState extends State<DealPagedListView>
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
    } on Exception catch (error) {
      loggy.error(error);
      _pagingController.error = error;
    }
  }

  void onEditButtonPressed(Deal deal) =>
      NavigationUtil.navigate(context, UpdateDeal(deal: deal));

  void onFavoriteButtonPressed(MyUser? user, String dealId, bool isFavorited) {
    if (user == null) {
      GetIt.I.get<SignInDialog>().showSignInDialog(context);

      return;
    }

    if (!isFavorited) {
      GetIt.I.get<SpringService>().favoriteDeal(dealId: dealId).then((result) {
        if (result) {
          Provider.of<UserController>(context, listen: false).getUser();
        } else {
          final snackBar = CustomSnackBar(
            icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
            text: l(context).favoriteDealError,
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    } else {
      GetIt.I
          .get<SpringService>()
          .unfavoriteDeal(dealId: dealId)
          .then((result) {
        if (result) {
          Provider.of<UserController>(context, listen: false).getUser();
          if (widget.removeDealWhenUnfavorited) {
            _pagingController.itemList!.removeWhere((e) => e.id == dealId);
          }
        } else {
          final snackBar = CustomSnackBar(
            icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
            text: l(context).unfavoriteDealError,
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }
  }

  Future<void> onDeleteButtonPressed(MyUser? user, Deal deal) async {
    if (user == null) {
      GetIt.I.get<SignInDialog>().showSignInDialog(context);
      return;
    }

    final didRequestDelete = await CustomAlertDialog(
          title: l(context).deleteConfirm,
          cancelActionText: l(context).cancel,
          defaultActionText: l(context).delete,
        ).show(context) ??
        false;
    if (didRequestDelete) {
      GetIt.I
          .get<SpringService>()
          .deleteDeal(dealId: deal.id!)
          .then((result) async {
        // Deletes the deal images.
        await GetIt.I
            .get<FirebaseStorageService>()
            .deleteImagesFromUrl(urls: [deal.coverPhoto, ...deal.photos!]);
        if (result) {
          _pagingController.refresh();
        } else {
          final snackBar = CustomSnackBar(
            icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
            text: l(context).deleteDealError,
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserController>(context).user;
    final searchHitsIsNotEmpty = _searchResponse?.hits.docCount != 0;
    final itemListIsEmpty = _pagingController.itemList?.isEmpty ?? false;
    final shouldShowFilterBar = widget.showFilterBar && _pagingStatus != null;
    final shouldShowTryAgainButton = shouldShowFilterBar &&
        widget.searchParams?.filterCount != 0 &&
        itemListIsEmpty;

    Widget buildPagedListView() => PagedListView(
          pagingController: _pagingController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          builderDelegate: PagedChildBuilderDelegate<Deal>(
            animateTransitions: true,
            itemBuilder: (context, deal, index) {
              final isFavorited = user?.favorites![deal.id!] ?? false;

              return DealItem(
                deal: deal,
                index: index,
                isFavorited: isFavorited,
                onEditButtonPressed: () => onEditButtonPressed(deal),
                onFavoriteButtonPressed: () =>
                    onFavoriteButtonPressed(user, deal.id!, isFavorited),
                onDeleteButtonPressed: () => onDeleteButtonPressed(user, deal),
                pagingController: _pagingController,
                showControlButtons:
                    user != null && (deal.postedBy! == user.id!),
              );
            },
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
            noItemsFoundIndicatorBuilder: (context) => widget.noDealsFound,
          ),
        );

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
            title: l(context).couldNotFindAnyDeal,
            tryAgainText: l(context).resetFilters,
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
