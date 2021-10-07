import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../deal/report_user_dialog.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/custom_alert_dialog.dart';

enum _MessagePopup { blockUser, unblockUser, reportUser }

class MessageAppBar extends StatefulWidget {
  const MessageAppBar({required this.user2, Key? key}) : super(key: key);

  final MyUser user2;

  @override
  _MessageAppBarState createState() => _MessageAppBarState();
}

class _MessageAppBarState extends State<MessageAppBar> {
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
          margin: const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          content: Row(
            children: [
              const Icon(LineIcons.ban, size: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
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
          margin: const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          content: Row(
            children: [
              const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
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
          margin: const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          content: Row(
            children: [
              const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final MyUser _user = Provider.of<UserControllerImpl>(context).user!;
    final bool _isUserBlocked = _user.blockedUsers!.contains(widget.user2.uid);

    Future<void> _onPressedReport() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
            ReportUserDialog(reportedUserId: widget.user2.id!),
      );
    }

    return AppBar(
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<_MessagePopup>(
          icon: const Icon(FontAwesomeIcons.ellipsisV, size: 20),
          onSelected: (_MessagePopup result) {
            if (result == _MessagePopup.blockUser) {
              _confirmBlockUser(context);
            } else if (result == _MessagePopup.unblockUser) {
              _confirmUnblockUser(context);
            } else if (result == _MessagePopup.reportUser) {
              _onPressedReport();
            }
          },
          itemBuilder: (BuildContext context) => [
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
