import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/hotdeals_api.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../auth/presentation/user_controller.dart';

final updateNicknameControllerProvider = StateNotifierProvider.autoDispose<
        UpdateNicknameController,
        AsyncValue<bool>>((ref) => UpdateNicknameController(ref.read),
    name: 'UpdateNicknameControllerProvider');

class UpdateNicknameController extends StateNotifier<AsyncValue<bool>> {
  UpdateNicknameController(Reader read)
      : _hotdealsRepository = read(hotdealsRepositoryProvider),
        _userController = read(userProvider.notifier),
        super(const AsyncData(false));

  final HotdealsApi _hotdealsRepository;
  final UserController _userController;

  Future<void> updateNickname(String userId, String nickname) async {
    state = const AsyncLoading();

    final value = await AsyncValue.guard(() => _hotdealsRepository
        .updateUserNickname(userId: userId, nickname: nickname));
    if (value.hasError) {
      state = AsyncError(value.error!);
    } else {
      state = const AsyncData(true);
      await _userController.refreshUser();
    }
  }
}
