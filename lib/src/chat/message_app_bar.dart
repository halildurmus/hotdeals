import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/report.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/loading_dialog.dart';

enum _MessagePopup { blockUser, unblockUser, reportUser }

class MessageAppBar extends StatefulWidget {
  const MessageAppBar({required this.user2, Key? key}) : super(key: key);

  final MyUser user2;

  @override
  _MessageAppBarState createState() => _MessageAppBarState();
}

class _MessageAppBarState extends State<MessageAppBar> {
  late TextEditingController _messageController;
  bool _harassingCheckbox = false;
  bool _spamCheckbox = false;
  bool _otherCheckbox = false;

  Future<void> _confirmBlockUser(BuildContext context) async {
    final bool _didRequestBlockUser = await CustomAlertDialog(
          title: AppLocalizations.of(context)!.blockUser,
          content: AppLocalizations.of(context)!.blockConfirm,
          cancelActionText: AppLocalizations.of(context)!.cancel,
          defaultActionText: AppLocalizations.of(context)!.ok,
        ).show(context) ??
        false;

    if (_didRequestBlockUser == true) {
      final bool _result = await GetIt.I
          .get<SpringService>()
          .blockUser(userId: widget.user2.uid);

      if (_result) {
        await Provider.of<UserControllerImpl>(context, listen: false).getUser();

        final SnackBar snackBar = SnackBar(
          backgroundColor: Theme.of(context).backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          content: Row(
            children: <Widget>[
              const Icon(LineIcons.ban, size: 24.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.successfullyBlocked,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final SnackBar snackBar = SnackBar(
          backgroundColor: Theme.of(context).backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          content: Row(
            children: <Widget>[
              const Icon(FontAwesomeIcons.exclamationCircle, size: 20.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.anErrorOccurredWhileBlocking,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _confirmUnblockUser(BuildContext context) async {
    final bool _didRequestUnblockUser = await CustomAlertDialog(
          title: AppLocalizations.of(context)!.unblockUser,
          content: AppLocalizations.of(context)!.unblockConfirm,
          cancelActionText: AppLocalizations.of(context)!.cancel,
          defaultActionText: AppLocalizations.of(context)!.ok,
        ).show(context) ??
        false;

    if (_didRequestUnblockUser == true) {
      final bool _result = await GetIt.I
          .get<SpringService>()
          .unblockUser(userUid: widget.user2.uid);

      if (_result) {
        await Provider.of<UserControllerImpl>(context, listen: false).getUser();
      } else {
        final SnackBar snackBar = SnackBar(
          backgroundColor: Theme.of(context).backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          content: Row(
            children: <Widget>[
              const Icon(FontAwesomeIcons.exclamationCircle, size: 20.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .anErrorOccurredWhileUnblocking,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendReport(BuildContext context, String userId) async {
    GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

    final Report report = Report(
      reportedUser: widget.user2.id,
      reasons: <String>[
        if (_harassingCheckbox) 'Harassing',
        if (_spamCheckbox) 'Spam',
        if (_otherCheckbox) 'Other'
      ],
      message:
          _messageController.text.isNotEmpty ? _messageController.text : null,
    );

    final Report? sentReport =
        await GetIt.I.get<SpringService>().sendReport(report: report);

    // Pops the loading dialog.
    Navigator.of(context).pop();
    if (sentReport != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.successfullyReportedUser)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.anErrorOccurred),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final MyUser _user = Provider.of<UserControllerImpl>(context).user!;
    final bool _isUserBlocked = _user.blockedUsers!.contains(widget.user2.uid);

    Widget _buildReportDialog() {
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
                    AppLocalizations.of(context)!.reportUser,
                    style: textTheme.headline6,
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.harassing),
                    value: _harassingCheckbox,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _harassingCheckbox = newValue!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.spam),
                    value: _spamCheckbox,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _spamCheckbox = newValue!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.other),
                    value: _otherCheckbox,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _otherCheckbox = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _messageController,
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
                        onPressed: _harassingCheckbox ||
                                _spamCheckbox ||
                                _otherCheckbox
                            ? () => _sendReport(context, _user.id!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          primary: theme.colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.reportUser),
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

    Future<void> _onPressedReport() async {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return _buildReportDialog();
        },
      );
    }

    return AppBar(
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20.0),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: GestureDetector(
        onTap: () {},
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: widget.user2.avatar!,
              imageBuilder:
                  (BuildContext ctx, ImageProvider<Object> imageProvider) =>
                      CircleAvatar(backgroundImage: imageProvider, radius: 16),
              placeholder: (BuildContext context, String url) =>
                  const CircleAvatar(radius: 16),
            ),
            const SizedBox(width: 8),
            Text(
              widget.user2.nickname!,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyText2!.copyWith(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        PopupMenuButton<_MessagePopup>(
          icon: const Icon(
            FontAwesomeIcons.ellipsisV,
            size: 20.0,
          ),
          onSelected: (_MessagePopup result) {
            if (result == _MessagePopup.blockUser) {
              _confirmBlockUser(context);
            } else if (result == _MessagePopup.unblockUser) {
              _confirmUnblockUser(context);
            } else if (result == _MessagePopup.reportUser) {
              _onPressedReport();
            }
          },
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<_MessagePopup>>[
            PopupMenuItem<_MessagePopup>(
              value: _isUserBlocked
                  ? _MessagePopup.unblockUser
                  : _MessagePopup.blockUser,
              child: _isUserBlocked
                  ? Text(AppLocalizations.of(context)!.unblockUser)
                  : Text(AppLocalizations.of(context)!.blockUser),
            ),
            PopupMenuItem<_MessagePopup>(
              value: _MessagePopup.reportUser,
              child: Text(AppLocalizations.of(context)!.reportUser),
            ),
          ],
        ),
      ],
    );
  }
}
