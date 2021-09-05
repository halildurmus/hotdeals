import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_storage_service.dart';

typedef Json = Map<String, dynamic>;

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Reference refFromURL({required String url}) {
    return _storage.refFromURL(url);
  }

  @override
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    final Reference storageRef = _storage
        .ref()
        .child('uploads')
        .child('${DateTime.now().millisecondsSinceEpoch}-$fileName');
    final UploadTask uploadTask = storageRef.putFile(
      File(filePath),
      SettableMetadata(contentType: mimeType),
    );
    final TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<String> uploadUserAvatar({
    required String filePath,
    required String fileName,
    required String mimeType,
    required String userID,
  }) async {
    final Reference storageRef =
        _storage.ref().child('avatars').child(userID + '-' + fileName);
    final UploadTask uploadTask = storageRef.putFile(
      File(filePath),
      SettableMetadata(contentType: mimeType),
    );
    final TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }
}
