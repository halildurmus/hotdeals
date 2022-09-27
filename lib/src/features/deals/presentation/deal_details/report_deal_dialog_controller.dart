import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/hotdeals_api.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../domain/deal_report.dart';

final reportDealDialogControllerProvider =
    Provider.autoDispose<ReportDealDialogController>((ref) {
  final textController = TextEditingController();
  ref.onDispose(textController.dispose);
  return ReportDealDialogController(ref.read, textController);
}, name: 'ReportDealDialogControllerProvider');

class ReportDealDialogController {
  ReportDealDialogController(Reader read, this.messageTextController)
      : _hotdealsRepository = read(hotdealsRepositoryProvider);

  final HotdealsApi _hotdealsRepository;
  TextEditingController messageTextController;
  bool expiredCheckbox = false;
  bool repostCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;

  Future<void> sendReport({
    required String dealId,
    required VoidCallback onFailure,
    required VoidCallback onSuccess,
  }) async {
    final report = DealReport(
      reportedDeal: dealId,
      reasons: {
        if (expiredCheckbox) DealReportReason.expired,
        if (repostCheckbox) DealReportReason.repost,
        if (spamCheckbox) DealReportReason.spam,
        if (otherCheckbox) DealReportReason.other,
      },
      message: messageTextController.text.isNotEmpty
          ? messageTextController.text
          : null,
    );

    final result = await _hotdealsRepository.reportDeal(report: report);
    result ? onSuccess() : onFailure();
  }
}
