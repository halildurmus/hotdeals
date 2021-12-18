import 'package:flutter/material.dart';

import '../search/search_params.dart';
import '../utils/localization_util.dart';
import 'modal_handle.dart';

class ExpiredModalBottomSheet extends StatelessWidget {
  const ExpiredModalBottomSheet({
    Key? key,
    required this.onListTileTap,
    required this.searchParams,
  }) : super(key: key);

  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    final filters = <String, dynamic>{
      l(context).includeExpiredDeals: false,
      l(context).hideExpiredDeals: true
    };
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    void _onTap(bool isSelected, MapEntry filter, StateSetter modalSetState) {
      if (isSelected) {
        return;
      }
      searchParams.hideExpired = filter.value;
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
                        Text(l(context).expired, style: textTheme.headline6),
                      ],
                    ),
                  ),
                ],
              ),
              ...filters.entries.map((filter) {
                final isSelected = searchParams.hideExpired == filter.value;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
              }),
            ],
          ),
        ),
      ),
    );
  }
}
