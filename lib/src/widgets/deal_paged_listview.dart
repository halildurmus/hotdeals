import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:provider/provider.dart';

import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/spring_service.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/deal_item.dart';
import '../widgets/sign_in_dialog.dart';
import 'custom_snackbar.dart';

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
  late final PagingController<int, Deal> _pagingController;

  @override
  void initState() {
    _pagingController =
        widget.pagingController ?? PagingController<int, Deal>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
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
      GetIt.I.get<SignInDialog>().showSignInDialog(context);

      return;
    }

    if (!isFavorited) {
      GetIt.I
          .get<SpringService>()
          .favoriteDeal(dealId: dealId)
          .then((bool result) {
        if (result) {
          Provider.of<UserController>(context, listen: false).getUser();
        } else {
          final snackBar = CustomSnackBar(
            icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
            text: AppLocalizations.of(context)!.favoriteDealError,
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    } else {
      GetIt.I
          .get<SpringService>()
          .unfavoriteDeal(dealId: dealId)
          .then((bool result) {
        if (result) {
          Provider.of<UserController>(context, listen: false).getUser();
          if (widget.removeDealWhenUnfavorited) {
            _pagingController.itemList!.removeWhere((e) => e.id == dealId);
          }
        } else {
          final snackBar = CustomSnackBar(
            icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
            text: AppLocalizations.of(context)!.unfavoriteDealError,
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<UserController>(context).user;

    Widget buildPagedListView() {
      return PagedListView(
        pagingController: _pagingController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        builderDelegate: PagedChildBuilderDelegate<Deal>(
          animateTransitions: true,
          itemBuilder: (context, deal, index) {
            final bool isFavorited = user?.favorites![deal.id!] == true;

            return DealItem(
              deal: deal,
              index: index,
              isFavorited: isFavorited,
              onFavoriteButtonPressed: () =>
                  onFavoriteButtonPressed(user, deal.id!, isFavorited),
            );
          },
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
