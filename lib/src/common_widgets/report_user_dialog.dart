import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../helpers/context_extensions.dart';
import 'custom_snack_bar.dart';
import 'dialog_button.dart';
import 'loading_dialog.dart';
import 'report_user_dialog_controller.dart';

class ReportUserDialog extends ConsumerWidget with UiLoggy {
  const ReportUserDialog({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(reportUserDialogControllerProvider);

    Future<void> sendReport() async {
      unawaited(ref.read(loadingDialogProvider).showLoadingDialog(context));
      await controller.sendReport(
        userId: userId,
        onSuccess: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the ReportUserDialog.
          CustomSnackBar.success(text: context.l.successfullyReportedUser)
              .showSnackBar(context);
        },
        onFailure: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the ReportUserDialog.
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
                  context.l.reportUser,
                  style: context.textTheme.headline6,
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
                  text: context.l.reportUser,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
