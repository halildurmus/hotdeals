import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/hotdeals_api.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../auth/data/auth_api.dart';
import '../../../auth/data/firebase_auth_repository.dart';

final signOutControllerProvider =
    StateNotifierProvider.autoDispose<SignOutController, AsyncValue<bool>>(
        (ref) => SignOutController(ref.read),
        name: 'SignOutControllerProvider');

class SignOutController extends StateNotifier<AsyncValue<bool>> {
  SignOutController(Reader read)
      : _authRepository = read(authApiProvider),
        _hotdealsRepository = read(hotdealsRepositoryProvider),
        super(const AsyncData(false));

  final AuthApi _authRepository;
  final HotdealsApi _hotdealsRepository;

  Future<void> signOut() async {
    state = const AsyncLoading();
    final fcmTokenValue =
        await AsyncValue.guard(FirebaseMessaging.instance.getToken);
    if (fcmTokenValue.hasError || fcmTokenValue.value == null) {
      state = AsyncError(fcmTokenValue.error!);
      return;
    }

    await _hotdealsRepository.deleteFCMToken(token: fcmTokenValue.value!);
    final signOutValue = await AsyncValue.guard(_authRepository.signOut);
    state = signOutValue.hasError
        ? AsyncError(signOutValue.error!)
        : const AsyncData(true);
  }
}
