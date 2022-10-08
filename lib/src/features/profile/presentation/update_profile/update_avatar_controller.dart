import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../../../core/firebase_storage_service.dart';
import '../../../../core/hotdeals_api.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../../core/image_picker_service.dart';
import '../../../auth/presentation/user_controller.dart';

final updateAvatarControllerProvider =
    StateNotifierProvider.autoDispose<UpdateAvatarController, AsyncValue<bool>>(
        (ref) => UpdateAvatarController(ref.read),
        name: 'UpdateAvatarControllerProvider');

class UpdateAvatarController extends StateNotifier<AsyncValue<bool>> {
  UpdateAvatarController(Reader read)
      : _firebaseStorageService = read(firebaseStorageServiceProvider),
        _hotdealsRepository = read(hotdealsRepositoryProvider),
        _imagePickerService = read(imagePickerServiceProvider),
        _userController = read(userProvider.notifier),
        super(const AsyncData(false));

  final FirebaseStorageService _firebaseStorageService;
  final HotdealsApi _hotdealsRepository;
  final ImagePickerService _imagePickerService;
  final UserController _userController;

  Future<XFile?> pickAvatar(ImageSource imageSource) =>
      _imagePickerService.pickImage(source: imageSource, maxWidth: 1000);

  Future<String> uploadAvatar(XFile file, String userId) {
    final mimeType = lookupMimeType(file.name) ?? '';

    return _firebaseStorageService.uploadUserAvatar(
      filePath: file.path,
      fileName: file.name,
      mimeType: mimeType,
      userId: userId,
    );
  }

  Future<void> updateAvatar(String userId, ImageSource imageSource) async {
    state = const AsyncLoading();
    final pickedFile = await pickAvatar(imageSource);
    if (pickedFile == null) {
      state = const AsyncData(false);
      return;
    }

    final avatarValue =
        await AsyncValue.guard(() => uploadAvatar(pickedFile, userId));
    if (avatarValue.hasError) {
      state = AsyncError(avatarValue.error!);
      return;
    }

    final value = await AsyncValue.guard(() => _hotdealsRepository
        .updateUserAvatar(userId: userId, avatarUrl: avatarValue.value!));
    if (value.hasError) {
      state = AsyncError(value.error!);
    } else {
      state = const AsyncData(true);
      await _userController.refreshUser();
    }
  }
}
