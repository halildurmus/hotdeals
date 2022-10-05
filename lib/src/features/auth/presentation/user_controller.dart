import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hotdeals_api.dart';
import '../../../core/hotdeals_repository.dart';
import '../../notifications/application/notification_service.dart';
import '../data/firebase_auth_repository.dart';
import '../domain/my_user.dart';

final userProvider = StateNotifierProvider<UserController, MyUser?>(
    UserController.new,
    name: 'UserProvider');

class UserController extends StateNotifier<MyUser?> {
  UserController(Ref ref)
      : _hotdealsApi = ref.read(hotdealsRepositoryProvider),
        _notificationService = ref.read(notificationServiceProvider),
        _ref = ref,
        super(null) {
    ref.watch(idTokenChangesProvider).maybeWhen(
          data: _handleAuthStateChanges,
          orElse: () => null,
        );
  }

  final HotdealsApi _hotdealsApi;
  final NotificationService _notificationService;
  final Ref _ref;

  Future<void> _handleAuthStateChanges(User? user) async {
    if (user == null) {
      if (state == null) return;
      _ref.read(idTokenProvider.notifier).state = null;
      state = null;
      return;
    }

    _ref.read(idTokenProvider.notifier).state = await user.getIdToken();
    await refreshUser();
    await _notificationService.subscribe();
  }

  Future<MyUser?> refreshUser() async {
    final user = await AsyncValue.guard(_hotdealsApi.getMongoUser);
    state = user.value;
    return state;
  }
}
