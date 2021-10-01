import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:provider/provider.dart';

import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/deal_list_item.dart';
import 'error_indicator.dart';

class DealPagedListView extends StatefulWidget {
  const DealPagedListView({
    Key? key,
    required this.dealFuture,
    required this.noDealsFound,
    this.pageSize = 20,
    this.pagingController,
    this.removeDealWhenUnfavorited = false,
    this.useRefreshIndicator = true,
  }) : super(key: key);

  final Future<List<Deal>?> Function(int page, int size) dealFuture;
  final Widget noDealsFound;
  final int pageSize;
  final PagingController<int, Deal>? pagingController;
  final bool removeDealWhenUnfavorited;
  final bool useRefreshIndicator;

  @override
  _DealPagedListViewState createState() => _DealPagedListViewState();
}

class _DealPagedListViewState extends State<DealPagedListView>
    with NetworkLoggy {
  late PagingController<int, Deal> _pagingController;

  @override
  void initState() {
    _pagingController =
        widget.pagingController ?? PagingController<int, Deal>(firstPageKey: 0);
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

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await widget.dealFuture(pageKey, widget.pageSize);
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

  void onFavoriteButtonPressed(MyUser? user, String dealId, bool isFavorited) {
    if (user == null) {
      loggy.warning('You need to log in!');

      return;
    }

    if (!isFavorited) {
      GetIt.I
          .get<SpringService>()
          .favoriteDeal(dealId: dealId)
          .then((bool result) {
        if (result) {
          Provider.of<UserControllerImpl>(context, listen: false).getUser();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.favoriteDealError),
            ),
          );
        }
      });
    } else {
      GetIt.I
          .get<SpringService>()
          .unfavoriteDeal(dealId: dealId)
          .then((bool result) {
        if (result) {
          Provider.of<UserControllerImpl>(context, listen: false).getUser();
          if (widget.removeDealWhenUnfavorited) {
            final tempList = _pagingController.itemList;
            tempList!.removeWhere((e) => e.id == dealId);
            _pagingController.itemList = tempList;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unfavoriteDealError),
            ),
          );
        }
      });
    }
  }

  Widget buildFirstPageError({required VoidCallback onTryAgain}) {
    return ErrorIndicator(
      icon: Icons.wifi,
      title: AppLocalizations.of(context)!.noConnection,
      message: AppLocalizations.of(context)!.checkYourInternet,
      onTryAgain: onTryAgain,
    );
  }

  Widget buildNewPageError({required VoidCallback onTryAgain}) {
    return InkWell(
      onTap: onTryAgain,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.somethingWentWrong,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Icon(Icons.refresh, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<UserControllerImpl>(context).user;

    Widget buildPagedListView() {
      return PagedListView(
        pagingController: _pagingController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        builderDelegate: PagedChildBuilderDelegate<Deal>(
          animateTransitions: true,
          itemBuilder: (context, deal, index) {
            final bool isFavorited = user?.favorites![deal.id!] == true;

            return DealListItem(
              deal: deal,
              index: index,
              isFavorited: isFavorited,
              onFavoriteButtonPressed: () =>
                  onFavoriteButtonPressed(user, deal.id!, isFavorited),
            );
          },
          firstPageErrorIndicatorBuilder: (context) => buildFirstPageError(
            onTryAgain: () => _pagingController.refresh(),
          ),
          newPageErrorIndicatorBuilder: (context) => buildNewPageError(
            onTryAgain: () => _pagingController.refresh(),
          ),
          noItemsFoundIndicatorBuilder: (context) => widget.noDealsFound,
        ),
      );
    }

    if (!widget.useRefreshIndicator) {
      return buildPagedListView();
    }

    return RefreshIndicator(
      onRefresh: () => Future.sync(() => _pagingController.refresh()),
      child: buildPagedListView(),
    );
  }
}
