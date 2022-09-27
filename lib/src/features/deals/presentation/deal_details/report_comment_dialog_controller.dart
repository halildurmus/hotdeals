import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/hotdeals_api.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../domain/comment_report.dart';

final reportCommentDialogControllerProvider =
    Provider.autoDispose<ReportCommentDialogController>((ref) {
  final textController = TextEditingController();
  ref.onDispose(textController.dispose);
  return ReportCommentDialogController(ref.read, textController);
}, name: 'ReportCommentDialogControllerProvider');

class ReportCommentDialogController {
  ReportCommentDialogController(Reader read, this.messageTextController)
      : _hotdealsRepository = read(hotdealsRepositoryProvider);

  final HotdealsApi _hotdealsRepository;
  TextEditingController messageTextController;
  bool harassingCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;

  Future<void> sendReport({
    required String commentId,
    required String dealId,
    required VoidCallback onFailure,
    required VoidCallback onSuccess,
  }) async {
    final report = CommentReport(
      reportedComment: commentId,
      reasons: {
        if (harassingCheckbox) CommentReportReason.harassing,
        if (spamCheckbox) CommentReportReason.spam,
        if (otherCheckbox) CommentReportReason.other,
      },
      message: messageTextController.text.isNotEmpty
          ? messageTextController.text
          : null,
    );

    final result =
        await _hotdealsRepository.reportComment(dealId: dealId, report: report);
    result ? onSuccess() : onFailure();
  }
}
