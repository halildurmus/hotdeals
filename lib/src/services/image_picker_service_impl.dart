import 'package:image_picker/image_picker.dart';

import 'image_picker_service.dart';

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxHeight,
    double? maxWidth,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return _picker.pickImage(
      source: source,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }
}
