import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/browse/data/categories_provider.dart';
import '../features/browse/data/stores_provider.dart';
import '../features/search/domain/search_params.dart';
import '../features/search/domain/search_response.dart';
import '../helpers/context_extensions.dart';
import 'modal_handle.dart';

class FilterModalBottomSheet extends StatefulWidget {
  FilterModalBottomSheet.category({
    required this.buckets,
    required this.filters,
    required this.hintText,
    required this.onListTileTap,
    required this.title,
    super.key,
  }) {
    _filterType = FilterType.category;
  }

  FilterModalBottomSheet.price({
    required this.buckets,
    required this.filters,
    required this.hintText,
    required this.onListTileTap,
    required this.title,
    super.key,
  }) {
    _filterType = FilterType.price;
  }

  FilterModalBottomSheet.store({
    required this.buckets,
    required this.filters,
    required this.hintText,
    required this.onListTileTap,
    required this.title,
    super.key,
  }) {
    _filterType = FilterType.store;
  }

  final List<Bucket> buckets;
  late final FilterType _filterType;
  final List<Object> filters;
  final String hintText;
  final VoidCallback onListTileTap;
  final String title;

  @override
  State<FilterModalBottomSheet> createState() => _FilterModalBottomSheetState();
}

class _FilterModalBottomSheetState extends State<FilterModalBottomSheet> {
  late final FocusNode searchFocusNode;
  late final TextEditingController searchTextController;
  var isSearchModeActive = false;

  @override
  void initState() {
    searchFocusNode = FocusNode();
    searchTextController = TextEditingController()
      ..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, modalSetState) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: context.mq.size.height * .667,
          ),
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ModalHandle(),
                _ModalHeader(
                  filterType: widget._filterType,
                  hintText: widget.title,
                  onClearButtonPressed: () =>
                      modalSetState(searchTextController.clear),
                  onCloseButtonPressed: () => modalSetState(
                      () => isSearchModeActive = !isSearchModeActive),
                  onSearchButtonPressed: () {
                    modalSetState(
                        () => isSearchModeActive = !isSearchModeActive);
                    searchFocusNode.requestFocus();
                  },
                  searchFocusNode: searchFocusNode,
                  isSearchModeActive: isSearchModeActive,
                  searchTextController: searchTextController,
                  title: widget.title,
                ),
                Flexible(
                  child: _ModalBody(
                    buckets: widget.buckets,
                    filters: widget.filters,
                    filterType: widget._filterType,
                    onTap: () {
                      modalSetState(() {});
                      widget.onListTileTap();
                    },
                    isSearchModeActive: isSearchModeActive,
                    searchTextController: searchTextController,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModalHeader extends StatefulWidget {
  const _ModalHeader({
    required this.filterType,
    required this.hintText,
    required this.isSearchModeActive,
    required this.onClearButtonPressed,
    required this.onCloseButtonPressed,
    required this.onSearchButtonPressed,
    required this.searchFocusNode,
    required this.searchTextController,
    required this.title,
  });

  final FilterType filterType;
  final String hintText;
  final bool isSearchModeActive;
  final VoidCallback onClearButtonPressed;
  final VoidCallback onCloseButtonPressed;
  final VoidCallback onSearchButtonPressed;
  final FocusNode searchFocusNode;
  final TextEditingController searchTextController;
  final String title;

  @override
  State<_ModalHeader> createState() => _ModalHeaderState();
}

class _ModalHeaderState extends State<_ModalHeader> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.isSearchModeActive
                      ? widget.onCloseButtonPressed
                      : Navigator.of(context).pop,
                  icon: Icon(
                    widget.isSearchModeActive ? Icons.arrow_back : Icons.close,
                  ),
                  iconSize: 20,
                ),
                if (widget.isSearchModeActive)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: widget.searchTextController,
                        decoration: InputDecoration(
                          hintStyle: context.textTheme.bodyText1!.copyWith(
                            color: context.isLightMode
                                ? Colors.black54
                                : Colors.grey,
                          ),
                          hintText: widget.hintText,
                          suffixIcon:
                              widget.searchTextController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: widget.onClearButtonPressed,
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                        ),
                        focusNode: widget.searchFocusNode,
                      ),
                    ),
                  )
                else
                  Text(widget.title, style: context.textTheme.headline6),
              ],
            ),
          ),
        ),
        if (!widget.isSearchModeActive && widget.filterType != FilterType.price)
          IconButton(
            onPressed: widget.onSearchButtonPressed,
            icon: Icon(
              Icons.search,
              color: context.colorScheme.secondary,
            ),
          ),
      ],
    );
  }
}

class _ModalBody extends ConsumerWidget {
  const _ModalBody({
    required this.buckets,
    required this.filterType,
    required this.filters,
    required this.isSearchModeActive,
    required this.onTap,
    required this.searchTextController,
  });

  final List<Bucket> buckets;
  final FilterType filterType;
  final List<Object> filters;
  final bool isSearchModeActive;
  final VoidCallback onTap;
  final TextEditingController searchTextController;

  String getCategoryName(CategoriesController controller, BuildContext context,
          String category) =>
      controller.categoryNameFromCategory(
        category: category,
        locale: Localizations.localeOf(context),
      );

  String getStoreName(StoresController controller, String storeId) =>
      controller.storeByStoreId(storeId).name;

  String getTitle(CategoriesController categoriesController,
      StoresController storesController, BuildContext context, Bucket bucket) {
    switch (filterType) {
      case FilterType.category:
        return '${getCategoryName(categoriesController, context, bucket.key)} (${bucket.docCount})';
      case FilterType.price:
        final priceRange = PriceRange.fromString(bucket.key);

        return '${priceRange.formattedString} (${bucket.docCount})';
      case FilterType.store:
        return '${getStoreName(storesController, bucket.key)} (${bucket.docCount})';
      default:
        throw Exception('Invalid filterType: $filterType');
    }
  }

  bool filterBuckets(CategoriesController categoriesController,
      StoresController storesController, BuildContext context, Bucket bucket) {
    if ((!isSearchModeActive || searchTextController.text.isEmpty) &&
        filterType != FilterType.price) {
      return true;
    }

    final pattern = RegExp(searchTextController.text, caseSensitive: false);

    switch (filterType) {
      case FilterType.category:
        return getCategoryName(categoriesController, context, bucket.key)
            .contains(pattern);
      case FilterType.price:
        return bucket.docCount > 0;
      case FilterType.store:
        return getStoreName(storesController, bucket.key).contains(pattern);
      default:
        throw Exception('Invalid filterType: $filterType');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesController = ref.watch(categoriesProvider);
    final storesController = ref.watch(storesProvider);
    final filteredBuckets = buckets.where((b) =>
        filterBuckets(categoriesController, storesController, context, b));

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredBuckets.length,
      itemBuilder: (context, index) {
        final bucket = filteredBuckets.elementAt(index);
        final isSelected = filterType == FilterType.price
            ? filters.contains(PriceRange.fromString(bucket.key))
            : filters.contains(bucket.key);
        final trailing = isSelected
            ? Icon(Icons.check, color: context.colorScheme.secondary)
            : null;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          onTap: () {
            if (isSelected) {
              filterType == FilterType.price
                  ? filters.remove(PriceRange.fromString(bucket.key))
                  : filters.remove(bucket.key);
            } else {
              filterType == FilterType.price
                  ? filters.add(PriceRange.fromString(bucket.key))
                  : filters.add(bucket.key);
            }
            onTap();
          },
          title: Text(
            getTitle(categoriesController, storesController, context, bucket),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
          trailing: trailing,
        );
      },
    );
  }
}
