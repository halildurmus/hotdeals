import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';

import '../models/deal_report.dart';
import '../models/deal_report_reason.dart';
import '../services/spring_service.dart';
import '../widgets/loading_dialog.dart';

class ReportDealDialog extends StatefulWidget {
  const ReportDealDialog({Key? key, required this.reportedDealId})
      : super(key: key);

  final String reportedDealId;

  @override
  _ReportDealDialogState createState() => _ReportDealDialogState();
}

class _ReportDealDialogState extends State<ReportDealDialog> with UiLoggy {
  late final SpringService springService;
  late final TextEditingController messageController;
  bool repostCheckbox = false;
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
    final double deviceWidth = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    Future<void> sendReport() async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final DealReport report = DealReport(
        reportedDeal: widget.reportedDealId,
        reasons: [
          if (repostCheckbox) DealReportReason.repost,
          if (spamCheckbox) DealReportReason.spam,
          if (otherCheckbox) DealReportReason.other,
        ],
        message:
            messageController.text.isNotEmpty ? messageController.text : null,
      );

      final DealReport? sentReport =
          await GetIt.I.get<SpringService>().sendDealReport(report: report);
      loggy.info(sentReport);

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (sentReport != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.successfullyReportedDeal),
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.anErrorOccurred),
          ),
        );
      }
    }

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.reportDeal,
                  style: textTheme.headline6,
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.repost),
                  value: repostCheckbox,
                  onChanged: (bool? newValue) {
                    setState(() {
                      repostCheckbox = newValue!;
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
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: deviceWidth,
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: repostCheckbox || spamCheckbox || otherCheckbox
                          ? sendReport
                          : null,
                      style: ElevatedButton.styleFrom(
                        primary: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.reportDeal),
                    ),
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