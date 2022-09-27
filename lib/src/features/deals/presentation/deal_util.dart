import 'package:firebase_picture_uploader/firebase_picture_uploader.dart'
    show UploadAction, UploadJob;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_storage_service.dart';

class DealUtil {
  static bool isUploadInProgress(List<UploadJob> jobs) =>
      jobs.where((e) => e.uploadProcessing == true).isNotEmpty;

  static Future<List<String>> getDownloadUrls(List<UploadJob> jobs) =>
      Future.wait<String>(jobs
          .where((e) => e.storageReference != null)
          .map((e) => e.storageReference!.getDownloadURL()));

  static List<UploadJob> loadInitialImages(
    WidgetRef ref, {
    required List<String> photoUrls,
  }) {
    final firebaseStorageService = ref.read(firebaseStorageServiceProvider);
    return <UploadJob>[
      for (final url in photoUrls)
        UploadJob(action: UploadAction.actionUpload)
          ..storageReference = firebaseStorageService.refFromURL(url: url)
    ];
  }
}
