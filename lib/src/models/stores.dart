import 'package:get_it/get_it.dart';

import '../services/spring_service.dart';
import 'store.dart';

class Stores {
  List<Store>? _stores;
  List<Store>? get stores => _stores;

  Future<List<Store>> getStores() async {
    _stores = await GetIt.I.get<SpringService>().getStores();

    return _stores!;
  }

  Store findByStoreId(String storeId) {
    return _stores!.singleWhere((Store s) => s.id == storeId);
  }
}
