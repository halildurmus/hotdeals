import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';

import '../models/user_report.dart';
import '../models/user_report_reason.dart';
import '../services/spring_service.dart';
import '../widgets/loading_dialog.dart';

class ReportUserDialog extends StatefulWidget {
  const ReportUserDialog({Key? key, required this.reportedUserId})
      : super(key: key);

  final String reportedUserId;

  @override
  _ReportUserDialogState createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> with UiLoggy {
  late final SpringService springService;
  late final TextEditingController messageController;
  bool harassingCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;

  @override
  void initState() {
    springService = GetIt.I.get<SpringService>();
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Future<void> sendReport(BuildContext ctx) async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(ctx);

      final UserReport report = UserReport(
        reportedUser: widget.reportedUserId,
        reasons: [
          if (harassingCheckbox) UserReportReason.harassing,
          if (spamCheckbox) UserReportReason.spam,
          if (otherCheckbox) UserReportReason.other,
        ],
        message:
            messageController.text.isNotEmpty ? messageController.text : null,
      );

      final UserReport? sentReport =
          await GetIt.I.get<SpringService>().sendUserReport(report: report);
      loggy.info(sentReport);

      // Pops the loading dialog.
      Navigator.of(ctx).pop();
      if (sentReport != null) {
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(ctx)!.successfullyReportedUser),
          ),
        );
      } else {
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(ctx)!.anErrorOccurred),
          ),
        );
      }
    }

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, void Function(VoidCallback) setState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.reportUser,
                  style: textTheme.headline6,
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.harassing),
                  value: harassingCheckbox,
                  onChanged: (bool? newValue) {
                    setState(() {
                      harassingCheckbox = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.spam),
                  value: spamCheckbox,
                  onChanged: (bool? newValue) {
                    setState(() {
                      spamCheckbox = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.other),
                  value: otherCheckbox,
                  onChanged: (bool? newValue) {
                    setState(() {
                      otherCheckbox = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintStyle: textTheme.bodyText2!.copyWith(
                        color: theme.brightness == Brightness.light
                            ? Colors.black54
                            : Colors.grey),
                    hintText: AppLocalizations.of(context)!
                        .enterSomeDetailsAboutReport,
                  ),
                  minLines: 1,
                  maxLines: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed:
                        harassingCheckbox || spamCheckbox || otherCheckbox
                            ? () => sendReport(context)
                            : null,
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(deviceWidth, 45),
                      primary: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.reportUser),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
