import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../common_widgets/custom_snack_bar.dart';
import '../../../../../common_widgets/dialog_button.dart';
import '../../../../../common_widgets/loading_dialog.dart';
import '../../../../../helpers/context_extensions.dart';
import '../report_deal_dialog_controller.dart';

class ReportDealDialog extends ConsumerWidget {
  const ReportDealDialog({required this.dealId, super.key});

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(reportDealDialogControllerProvider);

    Future<void> sendReport() async {
      unawaited(ref.read(loadingDialogProvider).showLoadingDialog(context));
      await controller.sendReport(
        dealId: dealId,
        onSuccess: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the ReportDealDialog.
          CustomSnackBar.success(text: context.l.successfullyReportedComment)
              .showSnackBar(context);
        },
        onFailure: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the ReportDealDialog.
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
                  context.l.reportDeal,
                  style: context.textTheme.headline6,
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: Text(context.l.expired),
                  value: controller.expiredCheckbox,
                  onChanged: (newValue) =>
                      setState(() => controller.expiredCheckbox = newValue!),
                ),
                CheckboxListTile(
                  title: Text(context.l.repost),
                  value: controller.repostCheckbox,
                  onChanged: (newValue) =>
                      setState(() => controller.repostCheckbox = newValue!),
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
                  onPressed: controller.expiredCheckbox ||
                          controller.repostCheckbox ||
                          controller.spamCheckbox ||
                          controller.otherCheckbox
                      ? sendReport
                      : null,
                  text: context.l.reportDeal,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
