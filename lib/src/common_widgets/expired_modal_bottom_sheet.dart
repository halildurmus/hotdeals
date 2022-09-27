import 'package:flutter/material.dart';

import '../features/search/domain/search_params.dart';
import '../helpers/context_extensions.dart';
import 'modal_handle.dart';

class ExpiredModalBottomSheet extends StatelessWidget {
  const ExpiredModalBottomSheet({
    required this.onListTileTap,
    required this.searchParams,
    super.key,
  });

  final VoidCallback onListTileTap;
  final SearchParams searchParams;

  @override
  Widget build(BuildContext context) {
    final filters = <String, dynamic>{
      context.l.includeExpiredDeals: false,
      context.l.hideExpiredDeals: true
    };
    final size = context.mq.size;

    void onTap(bool isSelected, MapEntry filter, StateSetter modalSetState) {
      if (isSelected) return;
      searchParams.hideExpired = filter.value;
      modalSetState(() {});
      onListTileTap.call();
    }

    return StatefulBuilder(
      builder: (context, modalSetState) {
        return ConstrainedBox(
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
                            onPressed: Navigator.of(context).pop,
                            icon: const Icon(Icons.close),
                            iconSize: 20,
                          ),
                          Text(context.l.expired,
                              style: context.textTheme.headline6),
                        ],
                      ),
                    ),
                  ],
                ),
                ...filters.entries.map((filter) {
                  final isSelected = searchParams.hideExpired == filter.value;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    onTap: () => onTap(isSelected, filter, modalSetState),
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
                          ? context.colorScheme.secondary
                          : Colors.grey.shade600,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
