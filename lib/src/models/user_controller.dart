import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../services/api_repository.dart';
import 'my_user.dart';

/// A class that many Widgets can interact with to get logged in user,
/// logout user or listen to user changes.
///
/// Controllers glue Data Services to Flutter Widgets.
/// The [UserController] uses the [APIRepository] to get logged in user.
class UserController extends ChangeNotifier {
  MyUser? _user;

  MyUser? get user => _user;

  Future<MyUser?> getUser() async {
    _user = await GetIt.I.get<APIRepository>().getMongoUser();
    notifyListeners();

    return _user;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
