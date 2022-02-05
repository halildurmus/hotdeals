import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../deal/report_user_dialog.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_snackbar.dart';

enum _MessagePopup { blockUser, unblockUser, reportUser }

class MessageAppBar extends StatefulWidget {
  const MessageAppBar({required this.user2, Key? key}) : super(key: key);

  final MyUser user2;

  @override
  _MessageAppBarState createState() => _MessageAppBarState();
}

class _MessageAppBarState extends State<MessageAppBar> {
  Future<void> _confirmBlockUser(BuildContext context) async {
    final didRequestBlockUser = await CustomAlertDialog(
          title: l(context).blockUser,
          content: l(context).blockConfirm,
          cancelActionText: l(context).cancel,
          defaultActionText: l(context).ok,
        ).show(context) ??
        false;
    if (didRequestBlockUser == true) {
      final result = await GetIt.I
          .get<APIRepository>()
          .blockUser(userId: widget.user2.id!);
      if (result) {
        await Provider.of<UserController>(context, listen: false).getUser();
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.checkCircle, size: 20),
          text: l(context).successfullyBlocked,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
          text: l(context).anErrorOccurredWhileBlocking,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _confirmUnblockUser(BuildContext context) async {
    final didRequestUnblockUser = await CustomAlertDialog(
          title: l(context).unblockUser,
          content: l(context).unblockConfirm,
          cancelActionText: l(context).cancel,
          defaultActionText: l(context).ok,
        ).show(context) ??
        false;
    if (didRequestUnblockUser == true) {
      final result = await GetIt.I
          .get<APIRepository>()
          .unblockUser(userId: widget.user2.id!);
      if (result) {
        await Provider.of<UserController>(context, listen: false).getUser();
      } else {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
          text: l(context).anErrorOccurredWhileUnblocking,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final user = Provider.of<UserController>(context).user!;
    final isUserBlocked = user.blockedUsers!.contains(widget.user2.id!);

    Future<void> _onPressedReport() async => showDialog<void>(
          context: context,
          builder: (context) =>
              ReportUserDialog(reportedUserId: widget.user2.id!),
        );

    return AppBar(
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
      ),
      title: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: widget.user2.avatar!,
              imageBuilder: (ctx, imageProvider) =>
                  CircleAvatar(backgroundImage: imageProvider, radius: 16),
              placeholder: (context, url) => const CircleAvatar(radius: 16),
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
          icon: const Icon(Icons.more_vert),
          onSelected: (result) {
            if (result == _MessagePopup.blockUser) {
              _confirmBlockUser(context);
            } else if (result == _MessagePopup.unblockUser) {
              _confirmUnblockUser(context);
            } else if (result == _MessagePopup.reportUser) {
              _onPressedReport();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<_MessagePopup>(
              value: isUserBlocked
                  ? _MessagePopup.unblockUser
                  : _MessagePopup.blockUser,
              child: isUserBlocked
                  ? Text(l(context).unblockUser)
                  : Text(l(context).blockUser),
            ),
            PopupMenuItem<_MessagePopup>(
              value: _MessagePopup.reportUser,
              child: Text(l(context).reportUser),
            ),
          ],
        ),
      ],
    );
  }
}
