import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../helpers/context_extensions.dart';
import '../../../browse/data/stores_provider.dart';
import '../../../browse/domain/store.dart';
import '../deal_form_controller.dart';

class StoreDropdown extends ConsumerWidget {
  const StoreDropdown({this.selectedStoreId, super.key});

  final String? selectedStoreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(storesProvider).stores;
    final controller = ref.watch(dealFormControllerProvider);
    final selectedStore = selectedStoreId != null
        ? stores.singleWhere((store) => store.id == selectedStoreId)
        : controller.selectedStore;

    return DropdownButtonFormField<Store>(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: context.l.store,
      ),
      value: selectedStore,
      onChanged: ref.read(dealFormControllerProvider.notifier).onStoreChanged,
      selectedItemBuilder: (context) =>
          stores.map<Widget>((store) => Text(store.name)).toList(),
      items: stores
          .map(
            (value) => DropdownMenuItem<Store>(
              value: value,
              child: ListTile(
                title: Text(value.name),
                trailing: (controller.selectedStore == value)
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
