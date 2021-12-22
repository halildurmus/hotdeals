import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/categories.dart';
import '../models/stores.dart';
import '../search/filter_type.dart';
import '../search/search_params.dart';
import '../search/search_response.dart';
import 'modal_handle.dart';

class FilterModalBottomSheet extends StatefulWidget {
  FilterModalBottomSheet.category({
    Key? key,
    required this.buckets,
    required this.filters,
    required this.hintText,
    required this.onListTileTap,
    required this.title,
  }) : super(key: key) {
    _filterType = FilterType.category;
  }

  FilterModalBottomSheet.price({
    Key? key,
    required this.buckets,
    required this.filters,
    required this.hintText,
    required this.onListTileTap,
    required this.title,
  }) : super(key: key) {
    _filterType = FilterType.price;
  }

  FilterModalBottomSheet.store({
    Key? key,
    required this.buckets,
    required this.filters,
    required this.hintText,
    required this.onListTileTap,
    required this.title,
  }) : super(key: key) {
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
  bool searchMode = false;
  late final FocusNode searchFocusNode;
  late final TextEditingController searchTextController;

  @override
  void initState() {
    searchFocusNode = FocusNode();
    searchTextController = TextEditingController();
    searchTextController.addListener(() => setState(() {}));
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
    final size = MediaQuery.of(context).size;

    return StatefulBuilder(
      builder: (context, modalSetState) => ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height * .667),
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
                onCloseButtonPressed: () =>
                    modalSetState(() => searchMode = !searchMode),
                onSearchButtonPressed: () {
                  modalSetState(() => searchMode = !searchMode);
                  searchFocusNode.requestFocus();
                },
                searchFocusNode: searchFocusNode,
                searchMode: searchMode,
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
                  searchMode: searchMode,
                  searchTextController: searchTextController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatefulWidget {
  const _ModalHeader({
    Key? key,
    required this.filterType,
    required this.hintText,
    required this.onClearButtonPressed,
    required this.onCloseButtonPressed,
    required this.onSearchButtonPressed,
    required this.searchMode,
    required this.searchFocusNode,
    required this.searchTextController,
    required this.title,
  }) : super(key: key);

  final FilterType filterType;
  final String hintText;
  final VoidCallback onClearButtonPressed;
  final VoidCallback onCloseButtonPressed;
  final VoidCallback onSearchButtonPressed;
  final bool searchMode;
  final FocusNode searchFocusNode;
  final TextEditingController searchTextController;
  final String title;

  @override
  State<_ModalHeader> createState() => _ModalHeaderState();
}

class _ModalHeaderState extends State<_ModalHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (widget.searchMode) {
                      widget.onCloseButtonPressed();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(
                    widget.searchMode ? Icons.arrow_back : Icons.close,
                  ),
                  iconSize: 20,
                ),
                if (widget.searchMode)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: widget.searchTextController,
                        decoration: InputDecoration(
                          hintStyle: textTheme.bodyText1!.copyWith(
                            color: theme.brightness == Brightness.light
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
                  Text(widget.title, style: textTheme.headline6),
              ],
            ),
          ),
        ),
        if (!widget.searchMode && widget.filterType != FilterType.price)
          IconButton(
            onPressed: widget.onSearchButtonPressed,
            icon: Icon(
              Icons.search,
              color: theme.colorScheme.secondary,
            ),
          ),
      ],
    );
  }
}

class _ModalBody extends StatelessWidget {
  const _ModalBody({
    Key? key,
    required this.buckets,
    required this.filterType,
    required this.filters,
    required this.onTap,
    required this.searchMode,
    required this.searchTextController,
  }) : super(key: key);

  final List<Bucket> buckets;
  final FilterType filterType;
  final List<Object> filters;
  final VoidCallback onTap;
  final bool searchMode;
  final TextEditingController searchTextController;

  String getCategoryName(BuildContext context, String category) =>
      GetIt.I.get<Categories>().getCategoryNameFromCategory(
            category: category,
            locale: Localizations.localeOf(context),
          );

  String getStoreName(String storeId) =>
      GetIt.I.get<Stores>().getStoreByStoreId(storeId).name;

  String getTitle(BuildContext context, Bucket bucket) {
    switch (filterType) {
      case FilterType.category:
        return '${getCategoryName(context, bucket.key)} (${bucket.docCount})';
      case FilterType.price:
        final priceRange = PriceRange.fromString(bucket.key);

        return '${priceRange.formattedString} (${bucket.docCount})';
      case FilterType.store:
        return '${getStoreName(bucket.key)} (${bucket.docCount})';
      default:
        throw Exception('Invalid filterType: $filterType');
    }
  }

  bool filterBuckets(BuildContext context, Bucket bucket) {
    if ((!searchMode || searchTextController.text.isEmpty) &&
        filterType != FilterType.price) {
      return true;
    }
    final pattern = RegExp(searchTextController.text, caseSensitive: false);

    switch (filterType) {
      case FilterType.category:
        return getCategoryName(context, bucket.key).contains(pattern);
      case FilterType.price:
        return bucket.docCount > 0;
      case FilterType.store:
        return getStoreName(bucket.key).contains(pattern);
      default:
        throw Exception('Invalid filterType: $filterType');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredBuckets = buckets.where((b) => filterBuckets(context, b));

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredBuckets.length,
      itemBuilder: (context, index) {
        final bucket = filteredBuckets.elementAt(index);
        final isSelected = filterType == FilterType.price
            ? filters.contains(PriceRange.fromString(bucket.key))
            : filters.contains(bucket.key);
        final trailing = isSelected
            ? Icon(
                Icons.check,
                color: theme.colorScheme.secondary,
              )
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
            getTitle(context, bucket),
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
