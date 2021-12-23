import 'package:firebase_picture_uploader/firebase_picture_uploader.dart'
    show UploadJob;

class DealUtil {
  static bool isUploadInProgress(List<UploadJob> jobs) =>
      jobs.where((e) => e.uploadProcessing == true).isNotEmpty;

  static Future<List<String>> getDownloadUrls(List<UploadJob> jobs) async =>
      Future.wait<String>(jobs
          .where((e) => e.storageReference != null)
          .map((e) => e.storageReference!.getDownloadURL()));
}
