import 'package:firebase_storage/firebase_storage.dart';

typedef Json = Map<String, dynamic>;

/// An abstract class that used for communicating with the [FirebaseStorage].
abstract class FirebaseStorageService {
  Future<String> uploadFile({
    required String filePath,
    required String mimeType,
  });

  Future<String> uploadUserAvatar({
    required String filePath,
    required String mimeType,
    required String userID,
  });
}
