import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebasePictureUploadController {
  FirebasePictureUploadController(FirebaseStorage storageInstance) {
    _storageInstance = storageInstance;

    SharedPreferences.getInstance()
        .then((sharedPref) => persistentKeyValueStore = sharedPref);
  }

  late FirebaseStorage _storageInstance;

  SharedPreferences? persistentKeyValueStore;

  Future<String?> receiveURL(
    String storageURL, {
    bool useCaching = true,
    bool storeInCache = true,
  }) async {
    // try getting the download link from persistence
    if (useCaching) {
      try {
        persistentKeyValueStore ??= await SharedPreferences.getInstance();
        final cachedURL = persistentKeyValueStore!.getString(storageURL);
        if (cachedURL != null) {
          return cachedURL;
        }
      } catch (_) {}
    }

    // if downloadLink is null get it from the storage
    try {
      final downloadLink =
          await _storageInstance.ref().child(storageURL).getDownloadURL();

      // cache link
      if (useCaching || storeInCache) {
        await persistentKeyValueStore!.setString(storageURL, downloadLink);
      }

      // give url to caller
      return downloadLink;
    } on Exception {
      // print(error);
      // print(stackTrace);
    }

    return null;
  }

  Future<Reference> uploadProfilePicture(
      File image, String uploadDirectory, int id) async {
    final uploadPath = '$uploadDirectory${id.toString()}_800.jpg';
    final imgRef = _storageInstance.ref().child(uploadPath);

    // start upload
    final uploadTask =
        imgRef.putFile(image, SettableMetadata(contentType: 'image/jpg'));

    // wait until upload is complete
    try {
      await uploadTask;
    } on Exception catch (error, stackTrace) {
      throw Exception('Upload failed, Firebase Error: $error $stackTrace');
    }

    return imgRef;
  }

  Future<void> deleteProfilePicture(Reference oldUpload) async {
    // ask backend to transform images
    await oldUpload.delete();
  }
}
