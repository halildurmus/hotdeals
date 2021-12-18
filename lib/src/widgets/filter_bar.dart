import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../search/search_params.dart';
import '../search/search_response.dart';
import '../utils/localization_util.dart';
import 'custom_alert_dialog.dart';
import 'custom_filter_chip.dart';
import 'expired_filter_chip.dart';
import 'expired_modal_bottom_sheet.dart';
import 'filter_modal_bottom_sheet.dart';
import 'sort_filter_chip.dart';
import 'sort_modal_bottom_sheet.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({
    Key? key,
    required this.pagingController,
    required this.searchParams,
    required this.searchResponse,
  }) : super(key: key);

  final PagingController pagingController;
  final SearchParams searchParams;
  final SearchResponse? searchResponse;

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  void onListTileTap() {
    setState(() {});
    widget.pagingController.refresh();
  }

  void onPressedReset() async {
    final bool didRequestReset = await CustomAlertDialog(
          title: l(context).resetAllFilters,
          cancelActionText: l(context).cancel,
          defaultActionText: l(context).ok,
        ).show(context) ??
        false;
    if (didRequestReset) {
      setState(() => widget.searchParams.reset());
      widget.pagingController.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    l(context)
                        .resultCount(widget.searchResponse?.hits.docCount ?? 0),
                  ),
                  if (widget.searchParams.filterCount > 0)
                    _ResetFiltersChip(
                      filterCount: widget.searchParams.filterCount,
                      onPressed: onPressedReset,
                    ),
                  _CategoryFilterChip(
                    buckets: widget.searchResponse!.aggCategory!.buckets,
                    onListTileTap: onListTileTap,
                    searchParams: widget.searchParams,
                  ),
                  _PriceFilterChip(
                    buckets: widget.searchResponse!.aggPrice!.buckets,
                    onListTileTap: onListTileTap,
                    searchParams: widget.searchParams,
                  ),
                  _StoreFilterChip(
                    buckets: widget.searchResponse!.aggStore!.buckets,
                    onListTileTap: onListTileTap,
                    searchParams: widget.searchParams,
                  ),
                  _ExpiredFilterChip(
                    onListTileTap: onListTileTap,
                    searchParams: widget.searchParams,
                  ),
                  _SortFilterChip(
                    onListTileTap: onListTileTap,
                    searchParams: widget.searchParams,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetFiltersChip extends StatelessWidget {
  const _ResetFiltersChip(
      {Key? key, required this.filterCount, required this.onPressed})
      : super(key: key);

  final int filterCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final borderSide = isDarkMode
        ? null
        : BorderSide(
            color: theme.chipTheme.backgroundColor.withOpacity(.07),
            width: .25,
          );

    return ActionChip(
      onPressed: onPressed,
      backgroundColor:
          isDarkMode ? null : theme.chipTheme.backgroundColor.withOpacity(.07),
      side: borderSide,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list,
            color: isDarkMode ? null : theme.colorScheme.secondaryVariant,
            size: 20,
          ),
          const SizedBox(width: 3),
          CircleAvatar(
            backgroundColor:
                isDarkMode ? Colors.white : theme.colorScheme.secondaryVariant,
            radius: 9,
            child: Text(
              filterCount.toString(),
              style: TextStyle(
                color: isDarkMode ? theme.colorScheme.secondary : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    Key? key,
    required this.buckets,
    required this.onListTileTap,
    required this.searchParams,
  }) : super(key: key);

  final List<Bucket> buckets;
  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return CustomFilterChip.category(
      filters: searchParams.categories,
      icon: Icons.category,
      label: l(context).category,
      labelPlural: l(context).categories,
      onSelected: (value) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => FilterModalBottomSheet.category(
          buckets: buckets,
          filters: searchParams.categories,
          hintText: l(context).filterCategories,
          onListTileTap: onListTileTap,
          title: l(context).filterByCategory,
        ),
      ),
    );
  }
}

class _PriceFilterChip extends StatelessWidget {
  const _PriceFilterChip({
    Key? key,
    required this.buckets,
    required this.onListTileTap,
    required this.searchParams,
  }) : super(key: key);

  final List<Bucket> buckets;
  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return CustomFilterChip.price(
      filters: searchParams.prices,
      icon: Icons.sell,
      label: l(context).price,
      labelPlural: l(context).prices,
      onSelected: (value) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => FilterModalBottomSheet.price(
          buckets: buckets,
          filters: searchParams.prices,
          hintText: l(context).filterPrices,
          onListTileTap: onListTileTap,
          title: l(context).filterByPrice,
        ),
      ),
    );
  }
}

class _StoreFilterChip extends StatelessWidget {
  const _StoreFilterChip({
    Key? key,
    required this.buckets,
    required this.onListTileTap,
    required this.searchParams,
  }) : super(key: key);

  final List<Bucket> buckets;
  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return CustomFilterChip.store(
      filters: searchParams.stores,
      icon: Icons.store,
      label: l(context).store,
      labelPlural: l(context).stores,
      onSelected: (value) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => FilterModalBottomSheet.store(
          buckets: buckets,
          filters: searchParams.stores,
          hintText: l(context).filterStores,
          onListTileTap: onListTileTap,
          title: l(context).filterByStore,
        ),
      ),
    );
  }
}

class _ExpiredFilterChip extends StatelessWidget {
  const _ExpiredFilterChip({
    Key? key,
    required this.onListTileTap,
    required this.searchParams,
  }) : super(key: key);

  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return ExpiredFilterChip(
      label: l(context).expired,
      onSelected: (value) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => ExpiredModalBottomSheet(
          onListTileTap: onListTileTap,
          searchParams: searchParams,
        ),
      ),
      hideExpired: searchParams.hideExpired,
    );
  }
}

class _SortFilterChip extends StatelessWidget {
  const _SortFilterChip({
    Key? key,
    required this.onListTileTap,
    required this.searchParams,
  }) : super(key: key);

  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return SortFilterChip(
      label: l(context).sort,
      onSelected: (value) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => SortModalBottomSheet(
          onListTileTap: onListTileTap,
          searchParams: searchParams,
        ),
      ),
      order: searchParams.order,
      sortBy: searchParams.sortBy,
    );
  }
}
