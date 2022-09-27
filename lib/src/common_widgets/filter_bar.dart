import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../features/search/domain/search_params.dart';
import '../features/search/domain/search_response.dart';
import '../helpers/context_extensions.dart';
import 'custom_alert_dialog.dart';
import 'custom_filter_chip.dart';
import 'expired_filter_chip.dart';
import 'expired_modal_bottom_sheet.dart';
import 'filter_modal_bottom_sheet.dart';
import 'sort_filter_chip.dart';
import 'sort_modal_bottom_sheet.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({
    required this.pagingController,
    required this.searchParams,
    required this.searchResponse,
    super.key,
  });

  final PagingController pagingController;
  final SearchParams searchParams;
  final SearchResponse? searchResponse;

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  void onListTileTap() {
    if (mounted) {
      setState(() {});
    }
    widget.pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                context.l
                    .resultCount(widget.searchResponse?.hits.docCount ?? 0),
              ),
              if (widget.searchParams.filterCount > 0)
                _ResetFiltersChip(
                  filterCount: widget.searchParams.filterCount,
                  onPressed: () => CustomAlertDialog(
                    title: context.l.resetAllFilters,
                    defaultAction: () {
                      if (mounted) {
                        setState(() {});
                      }
                      widget.searchParams.reset();
                      widget.pagingController.refresh();
                    },
                    cancelActionText: context.l.cancel,
                  ).show(context),
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
    );
  }
}

class _ResetFiltersChip extends StatelessWidget {
  const _ResetFiltersChip({required this.filterCount, required this.onPressed});

  final int filterCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final borderSide = context.isDarkMode
        ? null
        : BorderSide(
            color: context.t.chipTheme.backgroundColor!.withOpacity(.07),
            width: .25,
          );

    return ActionChip(
      onPressed: onPressed,
      backgroundColor: context.isDarkMode
          ? null
          : context.t.chipTheme.backgroundColor!.withOpacity(.07),
      side: borderSide,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list,
            color: context.isDarkMode
                ? null
                : context.colorScheme.secondaryContainer,
            size: 20,
          ),
          const SizedBox(width: 3),
          CircleAvatar(
            backgroundColor: context.isDarkMode
                ? Colors.white
                : context.colorScheme.secondaryContainer,
            radius: 9,
            child: Text(
              filterCount.toString(),
              style: TextStyle(
                color: context.isDarkMode
                    ? context.colorScheme.secondary
                    : Colors.white,
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
    required this.buckets,
    required this.onListTileTap,
    required this.searchParams,
  });

  final List<Bucket> buckets;
  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return CustomFilterChip.category(
      filters: searchParams.categories,
      icon: Icons.category,
      label: context.l.category,
      labelPlural: context.l.categories,
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
          hintText: context.l.filterCategories,
          onListTileTap: onListTileTap,
          title: context.l.filterByCategory,
        ),
      ),
    );
  }
}

class _PriceFilterChip extends StatelessWidget {
  const _PriceFilterChip({
    required this.buckets,
    required this.onListTileTap,
    required this.searchParams,
  });

  final List<Bucket> buckets;
  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return CustomFilterChip.price(
      filters: searchParams.prices,
      icon: Icons.sell,
      label: context.l.price,
      labelPlural: context.l.prices,
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
          hintText: context.l.filterPrices,
          onListTileTap: onListTileTap,
          title: context.l.filterByPrice,
        ),
      ),
    );
  }
}

class _StoreFilterChip extends StatelessWidget {
  const _StoreFilterChip({
    required this.buckets,
    required this.onListTileTap,
    required this.searchParams,
  });

  final List<Bucket> buckets;
  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return CustomFilterChip.store(
      filters: searchParams.stores,
      icon: Icons.store,
      label: context.l.store,
      labelPlural: context.l.stores,
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
          hintText: context.l.filterStores,
          onListTileTap: onListTileTap,
          title: context.l.filterByStore,
        ),
      ),
    );
  }
}

class _ExpiredFilterChip extends StatelessWidget {
  const _ExpiredFilterChip({
    required this.onListTileTap,
    required this.searchParams,
  });

  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return ExpiredFilterChip(
      label: context.l.expired,
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
    required this.onListTileTap,
    required this.searchParams,
  });

  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    return SortFilterChip(
      label: context.l.sort,
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
