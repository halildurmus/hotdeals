import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';

import '../models/user_report.dart';
import '../models/user_report_reason.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_dialog.dart';

class ReportUserDialog extends StatefulWidget {
  const ReportUserDialog({required this.reportedUserId, Key? key})
      : super(key: key);

  final String reportedUserId;

  @override
  _ReportUserDialogState createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> with UiLoggy {
  late final APIRepository apiRepository;
  late final TextEditingController messageController;
  bool harassingCheckbox = false;
  bool spamCheckbox = false;
  bool otherCheckbox = false;

  @override
  void initState() {
    apiRepository = GetIt.I.get<APIRepository>();
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

    Future<void> sendReport(BuildContext ctx) async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(ctx);

      final report = UserReport(
        reportedUser: widget.reportedUserId,
        reasons: {
          if (harassingCheckbox) UserReportReason.harassing,
          if (spamCheckbox) UserReportReason.spam,
          if (otherCheckbox) UserReportReason.other,
        },
        message:
            messageController.text.isNotEmpty ? messageController.text : null,
      );

      final sentReport =
          await GetIt.I.get<APIRepository>().reportUser(report: report);
      loggy.debug(sentReport);
      // Pops the loading dialog.
      Navigator.of(ctx).pop();
      if (sentReport) {
        Navigator.of(ctx).pop();
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.circleCheck, size: 20),
          text: l(context).successfullyReportedUser,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      } else {
        Navigator.of(ctx).pop();
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.circleExclamation, size: 20),
          text: l(context).anErrorOccurred,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
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
                l(context).reportUser,
                style: textTheme.headline6,
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: Text(l(context).harassing),
                value: harassingCheckbox,
                onChanged: (newValue) =>
                    setState(() => harassingCheckbox = newValue!),
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
                  onPressed: harassingCheckbox || spamCheckbox || otherCheckbox
                      ? () => sendReport(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(deviceWidth, 45),
                    primary: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(l(context).reportUser),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
