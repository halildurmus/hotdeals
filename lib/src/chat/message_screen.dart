import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../app_localizations.dart';
import '../models/current_route.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../settings/locales.dart' as locales;
import '../settings/settings_controller.dart';
import 'message_app_bar.dart';

typedef Json = Map<String, dynamic>;

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
  bool _isAttachmentUploading = false;
  final Uuid uuid = const Uuid();

  Future<void> _setAsSeen() async {
    final DocumentSnapshot<Json> _latestMessage = await FirebaseFirestore
        .instance
        .collection('messages')
        .doc(widget.docId)
        .get();

    final bool isLatestMessageEmpty =
        _latestMessage.get('latestMessage') == <dynamic>{};
    final String? latestMessageAuthorId =
        _latestMessage.get('latestMessage')['author']?['id'] as String?;

    if (!isLatestMessageEmpty && latestMessageAuthorId == widget.user2.uid) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.docId)
          .set(<String, dynamic>{
        'latestMessage': <String, dynamic>{
          'status': 'seen',
        },
      }, SetOptions(merge: true));
    }

    if (!isLatestMessageEmpty) {
      final QuerySnapshot<Json> _doc = await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.docId)
          .collection(widget.docId)
          .get();

      final Iterable<QueryDocumentSnapshot<Json>> _docs = _doc.docs.where(
          (QueryDocumentSnapshot<Json> element) =>
              element.data()['author']['id'] == widget.user2.uid);

      if (_docs.isNotEmpty) {
        _docs.forEach((QueryDocumentSnapshot<Json> doc) {
          doc.reference.update(<String, dynamic>{
            'status': 'seen',
          });
        });
      }
    }
  }

  Future<void> _sendPushNotification(String messageText) async {
    final PushNotification notification = PushNotification(
      title:
          '${widget.user2.nickname} ${AppLocalizations.of(context)!.sentYouMessage}',
      body: messageText,
      actor: widget.user2.nickname!,
      verb: 'message',
      object: widget.docId,
      message: messageText,
      uid: FirebaseAuth.instance.currentUser?.uid,
      avatar: widget.user2.avatar,
    );

    final bool result = await GetIt.I.get<SpringService>().sendPushNotification(
        notification: notification, tokens: widget.user2.fcmTokens!);

    if (result) {
      print('Push notification sent to: ${widget.user2.nickname}');
    }
  }

  Future<void> _onFileTap(types.FileMessage message) async {
    await OpenFile.open(message.uri);
  }

  Future<void> _onImageTap(types.ImageMessage message) async {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(message.name),
              titleSpacing: 0.0,
              leading: IconButton(
                icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20.0),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: PhotoView(
              imageProvider: NetworkImage(message.uri),
              backgroundDecoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      _onFileTap(message);
    } else if (message is types.ImageMessage) {
      _onImageTap(message);
    }
  }

  @override
  void initState() {
    _setAsSeen();
    super.initState();
  }

  @override
  void dispose() {
    GetIt.I.get<CurrentRoute>().clearRouteName();
    GetIt.I.get<CurrentRoute>().clearMessageArguments();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Locale currentLocale = GetIt.I.get<SettingsController>().locale;
    final ThemeData theme = Theme.of(context);
    final MyUser _user = Provider.of<UserControllerImpl>(context).user!;
    final bool _isUser2Blocked = _user.blockedUsers!.contains(widget.user2.uid);
    final bool _isUserBlocked = widget.user2.blockedUsers!.contains(_user.uid);

    Widget _buildBlockedText() {
      return Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: theme.brightness == Brightness.dark
              ? theme.primaryColorDark.withOpacity(.4)
              : theme.primaryColorLight.withOpacity(.7),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: _isUser2Blocked
            ? Text(AppLocalizations.of(context)!.youHaveBlockedThisUser)
            : Text(AppLocalizations.of(context)!.youHaveBeenBlockedByThisUser),
      );
    }

    Future<void> _sendMessage({
      types.FileMessage? fileMessage,
      types.ImageMessage? imageMessage,
      types.TextMessage? textMessage,
    }) async {
      final DocumentReference<Json> documentReference = FirebaseFirestore
          .instance
          .collection('messages')
          .doc(widget.docId)
          .collection(widget.docId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      final Json message = <String, dynamic>{
        'id': fileMessage?.id ?? imageMessage?.id ?? textMessage?.id,
        'author': <String, dynamic>{
          'id': fileMessage?.author.id ??
              imageMessage?.author.id ??
              textMessage?.author.id,
        },
        'createdAt': fileMessage?.createdAt ??
            imageMessage?.createdAt ??
            textMessage?.createdAt,
        if (imageMessage != null) 'height': imageMessage.height,
        if (fileMessage != null) 'mimeType': fileMessage.mimeType,
        if (fileMessage != null || imageMessage != null)
          'name': fileMessage?.name ?? imageMessage?.name,
        if (fileMessage != null || imageMessage != null)
          'size': fileMessage?.size ?? imageMessage?.size,
        'status': fileMessage?.status.toString().split('.').last ??
            imageMessage?.status.toString().split('.').last ??
            textMessage?.status.toString().split('.').last,
        if (textMessage != null) 'text': textMessage.text,
        'type': fileMessage != null
            ? 'file'
            : imageMessage != null
                ? 'image'
                : 'text',
        if (fileMessage != null || imageMessage != null)
          'uri': fileMessage?.uri ?? imageMessage?.uri,
        if (imageMessage != null) 'width': imageMessage.width,
      };

      await FirebaseFirestore.instance.runTransaction(
        (Transaction transaction) async {
          transaction.set(documentReference, message);
        },
      );

      final DocumentReference<Json> _latestMessage =
          FirebaseFirestore.instance.collection('messages').doc(widget.docId);

      await FirebaseFirestore.instance.runTransaction(
        (Transaction transaction) async {
          transaction.set(
            _latestMessage,
            <String, dynamic>{'latestMessage': message},
            SetOptions(merge: true),
          );
        },
      );

      setState(() {
        _isAttachmentUploading = false;
      });

      _sendPushNotification(fileMessage != null
          ? 'Sent you a file'
          : imageMessage != null
              ? 'Sent you an image'
              : textMessage!.text);
    }

    void _handleSendPressed(types.PartialText message) {
      final types.TextMessage textMessage = types.TextMessage(
        id: uuid.v4(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: types.Status.sent,
        author: types.User(id: _user.uid, imageUrl: _user.avatar),
        text: message.text,
      );

      _sendMessage(textMessage: textMessage);
    }

    Future<void> _handleFileSelection() async {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      setState(() {
        _isAttachmentUploading = true;
      });

      if (result != null) {
        final types.FileMessage message = types.FileMessage(
          id: uuid.v4(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          status: types.Status.sent,
          author: types.User(id: _user.uid, imageUrl: _user.avatar),
          mimeType: lookupMimeType(result.files.single.path),
          name: result.files.single.name,
          size: result.files.single.size,
          uri: result.files.single.path,
        );

        _sendMessage(fileMessage: message);
      } else {
        setState(() {
          _isAttachmentUploading = false;
        });
      }
    }

    Future<void> _handleImageSelection() async {
      final ImagePicker picker = ImagePicker();

      final PickedFile? pickedFile = await picker.getImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.camera,
      );

      setState(() {
        _isAttachmentUploading = true;
      });

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        final image = await decodeImageFromList(bytes);

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
          final types.ImageMessage message = types.ImageMessage(
            id: uuid.v4(),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            status: types.Status.sent,
            author: types.User(id: _user.uid, imageUrl: _user.avatar),
            height: image.height.toDouble(),
            name: pickedFile.path.split('/').last,
            size: bytes.length,
            uri: url,
            width: image.width.toDouble(),
          );

          _sendMessage(imageMessage: message);
        } else {
          setState(() {
            _isAttachmentUploading = false;
          });
        }
      }
    }

    Widget _buildAttachmentBottomSheet() {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  FontAwesomeIcons.times,
                  color: Color.fromRGBO(148, 148, 148, 1),
                  size: 20.0,
                ),
              ),
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.photo_camera),
              title: Text(AppLocalizations.of(context)!.image),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection();
              },
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.description),
              title: Text(AppLocalizations.of(context)!.file),
              onTap: () {
                Navigator.pop(context);
                _handleFileSelection();
              },
            ),
          ],
        ),
      );
    }

    void _handleAttachmentPressed() {
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        builder: (BuildContext context) {
          return _buildAttachmentBottomSheet();
        },
      );
    }

    Future<void> _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
    ) async {
      final QuerySnapshot<Json> _doc = await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.docId)
          .collection(widget.docId)
          .where('id', isEqualTo: message.id)
          .get();

      if (_doc.docs.isNotEmpty) {
        _doc.docs.first.reference.update(<String, dynamic>{
          'previewData': previewData.toJson(),
        });
      }
    }

    ChatTheme _chatTheme(ThemeData theme) {
      return DefaultChatTheme(
        backgroundColor: theme.backgroundColor,
        inputTextDecoration:
            const DefaultChatTheme().inputTextDecoration.copyWith(
                  fillColor: Colors.transparent,
                ),
        primaryColor: theme.brightness == Brightness.light
            ? theme.primaryColor
            : theme.primaryColorDark,
        secondaryColor: theme.brightness == Brightness.light
            ? theme.primaryColorLight.withOpacity(.2)
            : theme.primaryColorLight.withOpacity(.1),
        receivedMessageBodyTextStyle: theme.textTheme.bodyText2!.copyWith(
          color: theme.brightness == Brightness.light ? null : Colors.white,
          fontSize: 15.0,
        ),
        sentMessageBodyTextStyle: theme.textTheme.bodyText2!.copyWith(
          color: Colors.white,
          fontSize: 15.0,
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: MessageAppBar(user2: widget.user2),
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
            return const Center(child: CircularProgressIndicator());
          } else {
            final List<DocumentSnapshot<Json>> items = snapshot.data!.docs;

            final List<types.Message> messages = items
                .map((DocumentSnapshot<Json> i) {
                  final Json messageData = i.data()!;
                  final String id = messageData['id'] as String;
                  final int createdAt = messageData['createdAt'] as int;
                  final types.Status status =
                      (messageData['status'] as String) == 'seen'
                          ? types.Status.seen
                          : types.Status.sent;
                  final types.User author = types.User(
                    id: messageData['author']['id'] as String,
                    imageUrl: messageData['author']['id'] as String == _user.uid
                        ? _user.avatar!
                        : widget.user2.avatar!,
                  );
                  final String type = messageData['type'] as String;
                  final types.PreviewData? previewData =
                      messageData['previewData'] != null
                          ? types.PreviewData.fromJson(
                              messageData['previewData'] as Json)
                          : null;

                  if (type == 'file') {
                    return types.FileMessage(
                      id: id,
                      createdAt: createdAt,
                      status: status,
                      author: author,
                      mimeType: messageData['mimeType'] as String,
                      name: messageData['name'] as String,
                      size: messageData['size'] as int,
                      uri: messageData['uri'] as String,
                    );
                  } else if (type == 'image') {
                    return types.ImageMessage(
                      id: id,
                      createdAt: createdAt,
                      status: status,
                      author: author,
                      uri: messageData['uri'] as String,
                      name: messageData['name'] as String,
                      size: messageData['size'] as int,
                    );
                  } else {
                    return types.TextMessage(
                      id: id,
                      createdAt: createdAt,
                      status: status,
                      author: author,
                      previewData: previewData,
                      text: messageData['text'] as String,
                    );
                  }
                })
                .toList()
                .reversed
                .toList();

            return SafeArea(
              bottom: false,
              child: Chat(
                customBottomWidget: _isUser2Blocked || _isUserBlocked
                    ? _buildBlockedText()
                    : null,
                isAttachmentUploading: _isAttachmentUploading,
                dateLocale: Localizations.localeOf(context).languageCode,
                disableImageGallery: true,
                l10n: currentLocale == locales.tr_TR
                    ? const ChatL10nTr()
                    : const ChatL10nEn(),
                showUserAvatars: true,
                theme: _chatTheme(theme),
                messages: messages,
                onAttachmentPressed: _handleAttachmentPressed,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onSendPressed: _handleSendPressed,
                user: types.User(id: _user.uid, imageUrl: _user.avatar),
              ),
            );
          }
        },
      ),
    );
  }
}
