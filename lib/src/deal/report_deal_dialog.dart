import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';

import '../models/deal_report.dart';
import '../models/deal_report_reason.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_snackbar.dart';
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
  bool expiredCheckbox = false;
  bool repostCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;

  @override
  void initState() {
    springService = GetIt.I.get<SpringService>();
    messageController = TextEditingController();
    super.initState();
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

    Future<void> sendReport() async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final report = DealReport(
        reportedDeal: widget.reportedDealId,
        reasons: {
          if (expiredCheckbox) DealReportReason.expired,
          if (repostCheckbox) DealReportReason.repost,
          if (spamCheckbox) DealReportReason.spam,
          if (otherCheckbox) DealReportReason.other,
        },
        message:
            messageController.text.isNotEmpty ? messageController.text : null,
      );

      final sentReport =
          await GetIt.I.get<SpringService>().reportDeal(report: report);
      loggy.info(sentReport);
      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (sentReport) {
        Navigator.of(context).pop();
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.checkCircle, size: 20),
          text: l(context).successfullyReportedDeal,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        Navigator.of(context).pop();
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
          text: l(context).anErrorOccurred,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l(context).reportDeal,
                style: textTheme.headline6,
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: Text(l(context).expired),
                value: expiredCheckbox,
                onChanged: (newValue) =>
                    setState(() => expiredCheckbox = newValue!),
              ),
              CheckboxListTile(
                title: Text(l(context).repost),
                value: repostCheckbox,
                onChanged: (newValue) =>
                    setState(() => repostCheckbox = newValue!),
              ),
              CheckboxListTile(
                title: Text(l(context).spam),
                value: spamCheckbox,
                onChanged: (newValue) =>
                    setState(() => spamCheckbox = newValue!),
              ),
              CheckboxListTile(
                title: Text(l(context).other),
                value: otherCheckbox,
                onChanged: (newValue) =>
                    setState(() => otherCheckbox = newValue!),
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
                  hintText: l(context).enterSomeDetailsAboutReport,
                ),
                minLines: 1,
                maxLines: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: expiredCheckbox ||
                          repostCheckbox ||
                          spamCheckbox ||
                          otherCheckbox
                      ? sendReport
                      : null,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(deviceWidth, 45),
                    primary: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(l(context).reportDeal),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
