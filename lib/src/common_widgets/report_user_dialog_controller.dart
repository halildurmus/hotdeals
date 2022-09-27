import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/hotdeals_api.dart';
import '../core/hotdeals_repository.dart';
import '../features/auth/domain/user_report.dart';

final reportUserDialogControllerProvider =
    Provider.autoDispose<ReportUserDialogController>((ref) {
  final textController = TextEditingController();
  ref.onDispose(textController.dispose);
  return ReportUserDialogController(ref.read, textController);
}, name: 'ReportUserDialogControllerProvider');

class ReportUserDialogController {
  ReportUserDialogController(Reader read, this.messageTextController)
      : _hotdealsRepository = read(hotdealsRepositoryProvider);

  final HotdealsApi _hotdealsRepository;
  TextEditingController messageTextController;
  bool harassingCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;

  Future<void> sendReport({
    required String userId,
    required VoidCallback onFailure,
    required VoidCallback onSuccess,
  }) async {
    final report = UserReport(
      reportedUser: userId,
      reasons: {
        if (harassingCheckbox) UserReportReason.harassing,
        if (spamCheckbox) UserReportReason.spam,
        if (otherCheckbox) UserReportReason.other,
      },
      message: messageTextController.text.isNotEmpty
          ? messageTextController.text
          : null,
    );

    final result = await _hotdealsRepository.reportUser(report: report);
    result ? onSuccess() : onFailure();
  }
}
