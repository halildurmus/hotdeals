import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/store.dart';

final storesProvider = Provider<StoresController>((ref) => StoresController(),
    name: 'StoresProvider');

class StoresController {
  var stores = <Store>[];

  Store storeByStoreId(String storeId) =>
      stores.singleWhere((store) => store.id == storeId);
}
