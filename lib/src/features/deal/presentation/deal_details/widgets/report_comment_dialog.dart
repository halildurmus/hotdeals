import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../common_widgets/custom_snack_bar.dart';
import '../../../../../common_widgets/dialog_button.dart';
import '../../../../../helpers/context_extensions.dart';
import '../report_comment_dialog_controller.dart';

class ReportCommentDialog extends ConsumerStatefulWidget {
  const ReportCommentDialog({
    required this.commentId,
    required this.dealId,
    super.key,
  });

  final String commentId;
  final String dealId;

  @override
  ConsumerState<ReportCommentDialog> createState() =>
      _ReportCommentDialogState();
}

class _ReportCommentDialogState extends ConsumerState<ReportCommentDialog> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(reportCommentDialogControllerProvider);

    Future<void> sendReport() async {
      context.showLoadingDialog();
      await controller.sendReport(
        commentId: widget.commentId,
        dealId: widget.dealId,
        onSuccess: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the ReportCommentDialog.
          CustomSnackBar.success(text: context.l.successfullyReportedComment)
              .showSnackBar(context);
        },
        onFailure: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the ReportCommentDialog.
          const CustomSnackBar.error().showSnackBar(context);
        },
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l.reportComment,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: Text(context.l.harassing),
                  value: controller.harassingCheckbox,
                  onChanged: (newValue) =>
                      setState(() => controller.harassingCheckbox = newValue!),
                ),
                CheckboxListTile(
                  title: Text(context.l.spam),
                  value: controller.spamCheckbox,
                  onChanged: (newValue) =>
                      setState(() => controller.spamCheckbox = newValue!),
                ),
                CheckboxListTile(
                  title: Text(context.l.other),
                  value: controller.otherCheckbox,
                  onChanged: (newValue) =>
                      setState(() => controller.otherCheckbox = newValue!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.messageTextController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintStyle: context.textTheme.bodyText2!.copyWith(
                        color:
                            context.isLightMode ? Colors.black54 : Colors.grey),
                    hintText: context.l.enterSomeDetailsAboutReport,
                  ),
                  minLines: 1,
                  maxLines: 10,
                ),
                const SizedBox(height: 20),
                DialogButton(
                  onPressed: controller.harassingCheckbox ||
                          controller.spamCheckbox ||
                          controller.otherCheckbox
                      ? sendReport
                      : null,
                  text: context.l.reportComment,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
