import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:hotdeals/src/models/current_route.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/report.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/loading_dialog.dart';

typedef Json = Map<String, dynamic>;

enum _MessagePopup { blockUser, unblockUser, reportUser }

class MessageScreen extends StatefulWidget {
  const MessageScreen({required this.docId, required this.user2, Key? key})
      : super(key: key);

  final String docId;
  final MyUser user2;

  static const String routeName = '/message';

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  late TextEditingController _messageController;
  bool _harassingCheckbox = false;
  bool _spamCheckbox = false;
  bool _otherCheckbox = false;

  Future<void> _setAsRead() async {
    final DocumentSnapshot<Json> _latestMessage = await FirebaseFirestore
        .instance
        .collection('messages')
        .doc(widget.docId)
        .get();

    if (_latestMessage.get('latestMessage')['senderId'] == widget.user2.uid) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.docId)
          .set(<String, dynamic>{
        'latestMessage': <String, dynamic>{
          'isRead': true,
        },
      }, SetOptions(merge: true));
    }

    // final QuerySnapshot<Json> _doc = await FirebaseFirestore.instance
    //     .collection('messages')
    //     .doc(widget.docId)
    //     .collection(widget.docId)
    //     .where('senderId', isEqualTo: widget.user2.uid)
    //     .orderBy('sentAt')
    //     .limitToLast(1)
    //     .get();
    //
    // if (_doc.docs.isNotEmpty) {
    //   _doc.docs.first.reference.update(<String, dynamic>{
    //     'isRead': true,
    //   });
    // }
  }

  Future<void> _onSend(ChatMessage message) async {
    print(message.toJson());

    final DocumentReference<Json> documentReference = FirebaseFirestore.instance
        .collection('messages')
        .doc(widget.docId)
        .collection(widget.docId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    await FirebaseFirestore.instance.runTransaction(
      (Transaction transaction) async {
        transaction.set(
          documentReference,
          message.toJson(),
        );
      },
    );

    final DocumentReference<Json> _latestMessage =
        FirebaseFirestore.instance.collection('messages').doc(widget.docId);

    await FirebaseFirestore.instance.runTransaction(
      (Transaction transaction) async {
        transaction.set(
          _latestMessage,
          <String, dynamic>{
            'latestMessage': message.toJson(),
          },
          SetOptions(merge: true),
        );
      },
    );

    final PushNotification notification = PushNotification(
      title: '${widget.user2.nickname} sent you a message',
      body: message.text,
      actor: widget.user2.nickname!,
      verb: 'message',
      object: widget.docId,
      message: message.text,
      uid: FirebaseAuth.instance.currentUser?.uid,
      avatar: widget.user2.avatar,
    );

    final bool result = await GetIt.I.get<SpringService>().sendPushNotification(
        notification: notification, tokens: widget.user2.fcmTokens!);

    if (result) {
      print('Push notification sent to: ${widget.user2.nickname}');
    }
  }

  Future<void> _confirmBlockUser(BuildContext context) async {
    final bool _didRequestBlockUser = await const CustomAlertDialog(
          title: 'Block User',
          content: 'Are you sure that you want to block this user?',
          cancelActionText: 'Cancel',
          defaultActionText: 'Ok',
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
                    'The user has been blocked.',
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
                    'An error occurred while blocking this user.',
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
    final bool _didRequestUnblockUser = await const CustomAlertDialog(
          title: 'Unblock User',
          content: 'Are you sure that you want to unblock this user?',
          cancelActionText: 'Cancel',
          defaultActionText: 'Ok',
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
                    'An error occurred while unblocking the user.',
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
    _setAsRead();
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    GetIt.I.get<CurrentRoute>().clearRouteName();
    GetIt.I.get<CurrentRoute>().clearMessageArguments();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final MyUser _user = Provider.of<UserControllerImpl>(context).user!;
    final bool _isUserBlocked = _user.blockedUsers!.contains(widget.user2.uid);

    Future<void> _sendReport(BuildContext context) async {
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final Report report = Report(
        reportedBy: _user.id!,
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
      print(sentReport);

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (sentReport != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reported User')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred!'),
          ),
        );
      }
    }

    Future<void> _onPressedReport() async {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Report User',
                        style: textTheme.headline6,
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        title: const Text('Harassing'),
                        value: _harassingCheckbox,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _harassingCheckbox = newValue!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Spam'),
                        value: _spamCheckbox,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _spamCheckbox = newValue!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Other'),
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
                          hintText:
                              'Enter some details about your report here...',
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
                                ? () => _sendReport(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              primary: theme.colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Text('Report User'),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            size: 20.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: () {},
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 16.0,
                backgroundImage: NetworkImage(widget.user2.avatar!),
              ),
              const SizedBox(width: 8),
              Text(
                widget.user2.nickname!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
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
                    ? const Text('Unblock User')
                    : const Text('Block User'),
              ),
              const PopupMenuItem<_MessagePopup>(
                value: _MessagePopup.reportUser,
                child: Text('Report User'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Json>>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.docId)
            .collection(widget.docId)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Json>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final List<DocumentSnapshot<Json>> items = snapshot.data!.docs;

            final List<ChatMessage> messages =
                items.map((DocumentSnapshot<Json> i) {
              return ChatMessage.fromJson(i.data()!);
            }).toList();

            return DashChat(
              userId: _user.uid,
              readOnly: _isUserBlocked,
              key: _chatViewKey,
              onTap: () async {
                _setAsRead();
              },
              inverted: false,
              onSend: _onSend,
              sendOnEnter: true,
              textInputAction: TextInputAction.newline,
              messages: messages,
              showUserAvatar: false,
              scrollToBottomStyle: ScrollToBottomStyle(bottom: 85.0),
              avatarBuilder: (String userId) {
                return ClipOval(
                  child: FadeInImage.memoryNetwork(
                    image: userId == _user.uid
                        ? _user.avatar!
                        : widget.user2.avatar!,
                    placeholder: kTransparentImage,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.width * .1,
                    width: MediaQuery.of(context).size.width * .1,
                  ),
                );
              },
              showAvatarForEveryMessage: false,
              scrollToBottom: true,
              onPressAvatar: (String user) {},
              onLongPressAvatar: (String user) {
                print('OnLongPressAvatar: $user');
              },
              alwaysShowSend: true,
              onQuickReply: (Reply reply) {},
              onLoadEarlier: () {
                print('Loading...');
              },
              inputContainerStyle: BoxDecoration(
                border: Border.all(color: theme.primaryColor),
                borderRadius: BorderRadius.circular(24.0),
                color: theme.backgroundColor,
              ),
              inputDecoration: const InputDecoration.collapsed(
                hintText: 'Mesajınızı buraya yazın',
              ),
              inputMaxLines: 5,
              inputToolbarPadding: const EdgeInsets.only(
                left: 8.0,
                top: 2.0,
                bottom: 2.0,
              ),
              inputTextStyle: const TextStyle(fontSize: 16.0),
              inputToolbarMargin: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 16.0,
              ),
              messageContainerPadding:
                  const EdgeInsets.symmetric(horizontal: 5.0),
              messageDecorationBuilder: (ChatMessage msg, bool? isUser) {
                return BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: isUser!
                        ? theme.brightness == Brightness.light
                            ? theme.primaryColor.withOpacity(.8)
                            : theme.primaryColorDark
                        : theme.primaryColorLight.withOpacity(.1));
              },
              messagePadding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
              messageTextBuilder: (String? text, [ChatMessage? message]) {
                if (text!.isEmpty) {
                  return const SizedBox();
                }

                return Text(
                  text,
                  style: TextStyle(
                    color: message!.senderId == _user.uid ? Colors.white : null,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
              messageTimeBuilder: (String text, [ChatMessage? message]) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      color:
                          message!.senderId == _user.uid ? Colors.white : null,
                      fontSize: 12.0,
                    ),
                  ),
                );
              },
              textBeforeImage: false,
              shouldShowLoadEarlier: false,
              showTrailingBeforeSend: true,
              trailing: <Widget>[
                IconButton(
                  icon: const Icon(Icons.photo),
                  color: theme.primaryColor,
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final PickedFile? pickedFile = await picker.getImage(
                      source: ImageSource.camera,
                      maxHeight: 1080,
                      maxWidth: 1920,
                    );

                    if (pickedFile != null) {
                      final Reference storageRef = FirebaseStorage.instance
                          .ref()
                          .child('chat_images')
                          .child(DateTime.now().toString());

                      final UploadTask uploadTask = storageRef.putFile(
                        File(pickedFile.path),
                        SettableMetadata(
                          contentType: 'image/jpg',
                        ),
                      );

                      final TaskSnapshot snapshot = await uploadTask;
                      final String url = await snapshot.ref.getDownloadURL();

                      if (url != null) {
                        _onSend(
                          ChatMessage(
                            senderId: _user.uid,
                            image: url,
                            text: '',
                          ),
                        );
                      }
                    }
                  },
                )
              ],
            );
          }
        },
      ),
    );
  }
}
