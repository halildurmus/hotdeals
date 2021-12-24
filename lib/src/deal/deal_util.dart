import 'package:firebase_picture_uploader/firebase_picture_uploader.dart'
    show UploadAction, UploadJob;
import 'package:get_it/get_it.dart';

import '../services/firebase_storage_service.dart';

class DealUtil {
  static bool isUploadInProgress(List<UploadJob> jobs) =>
      jobs.where((e) => e.uploadProcessing == true).isNotEmpty;

  static Future<List<String>> getDownloadUrls(List<UploadJob> jobs) async =>
      Future.wait<String>(jobs
          .where((e) => e.storageReference != null)
          .map((e) => e.storageReference!.getDownloadURL()));

  static List<UploadJob> loadInitialImages({required List<String> photos}) {
    final firebaseStorageService = GetIt.I.get<FirebaseStorageService>();
    final uploadJobs = <UploadJob>[];
    for (final url in photos) {
      final uploadJob = UploadJob(action: UploadAction.actionUpload)
        ..storageReference = firebaseStorageService.refFromURL(url: url);
      uploadJobs.add(uploadJob);
    }

    return uploadJobs;
  }
}
