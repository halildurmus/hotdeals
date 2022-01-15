import 'package:flutter/material.dart';

import '../search/search_params.dart';
import '../utils/localization_util.dart';
import 'modal_handle.dart';

class SortModalBottomSheet extends StatelessWidget {
  const SortModalBottomSheet({
    required this.onListTileTap,
    required this.searchParams,
    Key? key,
  }) : super(key: key);

  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    final filters = <String, dynamic>{
      l(context).relevant: {'sortBy': null, 'order': null},
      l(context).newest: {'sortBy': DealSortBy.createdAt, 'order': Order.asc},
      l(context).oldest: {'sortBy': DealSortBy.createdAt, 'order': Order.desc},
      l(context).priceLowToHigh: {
        'sortBy': DealSortBy.price,
        'order': Order.asc
      },
      l(context).priceHighToLow: {
        'sortBy': DealSortBy.price,
        'order': Order.desc
      }
    };
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;

    void _onTap(bool isSelected, MapEntry filter, StateSetter modalSetState) {
      if (isSelected) {
        return;
      }
      searchParams
        ..sortBy = filter.value['sortBy']
        ..order = filter.value['order'];
      modalSetState(() {});
      onListTileTap.call();
    }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                        ),
                        Text(l(context).sortBy, style: textTheme.headline6),
                      ],
                    ),
                  ),
                ],
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    final filter = filters.entries.elementAt(index);
                    final isSelected =
                        searchParams.sortBy == filter.value['sortBy'] &&
                            searchParams.order == filter.value['order'];

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      onTap: () => _onTap(isSelected, filter, modalSetState),
                      title: Text(
                        filter.key,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : Colors.grey.shade600,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      [0, 2, 4].contains(index)
                          ? Divider(
                              color: isDarkMode ? Colors.black : null,
                              thickness: 16,
                            )
                          : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
