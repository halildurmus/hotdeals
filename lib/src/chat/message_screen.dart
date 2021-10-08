import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/current_route.dart';
import '../models/my_user.dart';
import '../models/notification_verb.dart';
import '../models/push_notification.dart';
import '../models/user_controller_impl.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/image_picker_service.dart';
import '../services/spring_service.dart';
import '../settings/settings_controller.dart';
import '../utils/chat_util.dart';
import 'message_app_bar.dart';

typedef Json = Map<String, dynamic>;

const Map<String, types.Status> _statusEnumMap = {
  'delivered': types.Status.delivered,
  'error': types.Status.error,
  'seen': types.Status.seen,
  'sending': types.Status.sending,
  'sent': types.Status.sent
};

class MessageScreen extends StatefulWidget {
  const MessageScreen({required this.docId, required this.user2, Key? key})
      : super(key: key);

  final String docId;
  final MyUser user2;

  static const String routeName = '/message';

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with UiLoggy {
  bool _isAttachmentUploading = false;
  final Uuid uuid = const Uuid();

  Future<void> _markAsSeen() async {
    await GetIt.I
        .get<FirestoreService>()
        .markMessagesAsSeen(docID: widget.docId, user2Uid: widget.user2.uid);
  }

  Future<void> _sendPushNotification(MyUser user, types.Message message) async {
    String messageText = '';

    if (message is types.FileMessage) {
      messageText = AppLocalizations.of(context)!.file;
    } else if (message is types.ImageMessage) {
      messageText = AppLocalizations.of(context)!.image;
    } else if (message is types.TextMessage) {
      messageText = message.text;
    }

    final PushNotification notification = PushNotification(
      title: '${user.nickname} ${AppLocalizations.of(context)!.sentYouMessage}',
      body: messageText,
      actor: user.id!,
      verb: NotificationVerb.message,
      object: widget.docId,
      message: messageText,
      uid: widget.user2.uid,
      avatar: user.avatar,
    );

    final bool result = await GetIt.I.get<SpringService>().sendPushNotification(
        notification: notification, tokens: widget.user2.fcmTokens!);

    if (result) {
      loggy.info('Push notification sent to: ${widget.user2.nickname}');
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
              elevation: 0,
              title: Text(message.name),
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
              ),
            ),
            body: PhotoView(
              backgroundDecoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              filterQuality: FilterQuality.low,
              imageProvider: NetworkImage(message.uri),
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
    _markAsSeen();
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
    final theme = Theme.of(context);
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

    Future<void> _sendMessage(types.Message message) async {
      await GetIt.I.get<FirestoreService>().sendMessage(
          docID: widget.docId,
          message: ChatUtil.messageToJson(message: message));

      setState(() {
        _isAttachmentUploading = false;
      });

      _sendPushNotification(_user, message);
    }

    void _handleSendPressed(types.PartialText message) {
      final types.TextMessage textMessage = types.TextMessage(
        id: uuid.v4(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: types.Status.sent,
        author: types.User(id: _user.uid, imageUrl: _user.avatar),
        text: message.text,
      );

      _sendMessage(textMessage);
    }

    Future<void> _handleFileSelection() async {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      setState(() {
        _isAttachmentUploading = true;
      });

      if (result != null) {
        final PlatformFile pickedFile = result.files.single;
        final String mimeType = lookupMimeType(pickedFile.name) ?? '';
        final String url =
            await GetIt.I.get<FirebaseStorageService>().uploadFile(
                  filePath: pickedFile.path!,
                  fileName: pickedFile.name,
                  mimeType: mimeType,
                );

        final types.FileMessage fileMessage = types.FileMessage(
          id: uuid.v4(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          status: types.Status.sent,
          author: types.User(id: _user.uid, imageUrl: _user.avatar),
          mimeType: mimeType,
          name: pickedFile.name,
          size: pickedFile.size,
          uri: url,
        );

        _sendMessage(fileMessage);
      } else {
        setState(() {
          _isAttachmentUploading = false;
        });
      }
    }

    Future<void> _handleImageSelection() async {
      final XFile? pickedFile =
          await GetIt.I.get<ImagePickerService>().pickImage(
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
        final String mimeType = lookupMimeType(pickedFile.name) ?? '';
        final String url =
            await GetIt.I.get<FirebaseStorageService>().uploadFile(
                  filePath: pickedFile.path,
                  fileName: pickedFile.name,
                  mimeType: mimeType,
                );

        final types.ImageMessage imageMessage = types.ImageMessage(
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

        _sendMessage(imageMessage);
      } else {
        setState(() {
          _isAttachmentUploading = false;
        });
      }
    }

    Widget _buildAttachmentBottomSheet() {
      return SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      FontAwesomeIcons.times,
                      color: Color.fromRGBO(148, 148, 148, 1),
                      size: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      AppLocalizations.of(context)!.selectSource,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (BuildContext context) => _buildAttachmentBottomSheet(),
      );
    }

    Future<void> _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
    ) async {
      await GetIt.I.get<FirestoreService>().updateMessagePreview(
            docID: widget.docId,
            messageID: message.id,
            previewData: previewData.toJson(),
          );
    }

    ChatL10n _getChatL10n() {
      return currentLocale == kLocaleTurkish
          ? const ChatL10nTr()
          : const ChatL10nEn();
    }

    ChatTheme _chatTheme(ThemeData theme) {
      const defaultChatTheme = DefaultChatTheme();

      return DefaultChatTheme(
        backgroundColor: theme.backgroundColor,
        inputTextDecoration: defaultChatTheme.inputTextDecoration.copyWith(
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
          height: 1.3,
          fontSize: 15,
        ),
        receivedMessageLinkDescriptionTextStyle:
            defaultChatTheme.receivedMessageLinkDescriptionTextStyle.copyWith(
          color: theme.brightness == Brightness.light ? null : Colors.white,
        ),
        receivedMessageLinkTitleTextStyle:
            defaultChatTheme.receivedMessageLinkTitleTextStyle.copyWith(
          color: theme.brightness == Brightness.light ? null : Colors.white,
        ),
        sentMessageBodyTextStyle: theme.textTheme.bodyText2!.copyWith(
          color: Colors.white,
          height: 1.3,
          fontSize: 15,
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MessageAppBar(user2: widget.user2),
      ),
      body: StreamBuilder<QuerySnapshot<Json>>(
        stream: GetIt.I
            .get<FirestoreService>()
            .messagesStreamByDocID(docID: widget.docId),
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
                      _statusEnumMap[(messageData['status'] as String)] ??
                          types.Status.sent;
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
                      author: author,
                      status: status,
                      mimeType: messageData['mimeType'] as String,
                      name: messageData['name'] as String,
                      size: messageData['size'] as int,
                      uri: messageData['uri'] as String,
                    );
                  } else if (type == 'image') {
                    return types.ImageMessage(
                      id: id,
                      createdAt: createdAt,
                      author: author,
                      status: status,
                      height: messageData['height'] as double,
                      name: messageData['name'] as String,
                      size: messageData['size'] as int,
                      uri: messageData['uri'] as String,
                      width: messageData['width'] as double,
                    );
                  } else {
                    return types.TextMessage(
                      id: id,
                      createdAt: createdAt,
                      author: author,
                      status: status,
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
                l10n: _getChatL10n(),
                showUserAvatars: true,
                theme: _chatTheme(theme),
                messages: messages,
                onAttachmentPressed: _handleAttachmentPressed,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onTextFieldTap: () => _markAsSeen(),
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
