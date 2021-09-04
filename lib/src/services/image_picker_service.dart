import 'package:image_picker/image_picker.dart';

/// An abstract class that used for picking image/video with the [image_picker].
abstract class ImagePickerService {
  /// Returns an [XFile] object pointing to the image that was picked.
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxHeight,
    double? maxWidth,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  });
}
