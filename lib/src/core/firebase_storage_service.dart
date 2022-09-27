import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>(
    (ref) => throw UnimplementedError(),
    name: 'FirebaseStorageServiceProvider');

typedef Json = Map<String, dynamic>;

class FirebaseStorageService {
  const FirebaseStorageService(this._storage);

  final FirebaseStorage _storage;

  Reference refFromURL({required String url}) => _storage.refFromURL(url);

  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    final storageRef = _storage
        .ref()
        .child('uploads')
        .child('${DateTime.now().millisecondsSinceEpoch}-$fileName');
    final uploadTask = storageRef.putFile(
      File(filePath),
      SettableMetadata(contentType: mimeType),
    );
    final snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadUserAvatar({
    required String filePath,
    required String fileName,
    required String mimeType,
    required String userID,
  }) async {
    final storageRef =
        _storage.ref().child('avatars').child('$userID-$fileName');
    final uploadTask = storageRef.putFile(
      File(filePath),
      SettableMetadata(contentType: mimeType),
    );
    final snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImagesFromRef({required List<Reference> refs}) async =>
      Future.wait([...refs.map((e) => e.delete())]);

  Future<void> deleteImagesFromUrl(List<String> urls) async {
    final refs = <Reference>[...urls.map(_storage.refFromURL)];
    await deleteImagesFromRef(refs: refs);
  }
}
