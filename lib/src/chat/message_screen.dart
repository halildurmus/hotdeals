import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/current_route.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/user_controller.dart';
import '../services/api_repository.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/image_picker_service.dart';
import '../settings/settings.controller.dart';
import '../utils/chat_util.dart';
import '../utils/localization_util.dart';
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
  late final Locale _currentLocale;
  bool _isAttachmentUploading = false;
  final Uuid uuid = const Uuid();

  @override
  void initState() {
    _currentLocale = GetIt.I.get<SettingsController>().locale;
    _markAsSeen();
    super.initState();
  }

  @override
  void dispose() {
    GetIt.I.get<CurrentRoute>().routeName = '';
    GetIt.I.get<CurrentRoute>().messageArguments = null;
    super.dispose();
  }

  Future<void> _markAsSeen() async {
    await GetIt.I
        .get<FirestoreService>()
        .markMessagesAsSeen(docID: widget.docId, user2Uid: widget.user2.uid);
  }

  Future<void> _sendPushNotification(MyUser user, types.Message message) async {
    String? imageUrl;
    late final String titleLocKey;
    String? bodyLocKey;
    String? body;
    if (message is types.FileMessage) {
      titleLocKey = 'file_message_title';
      body = '📄 ${message.name}';
    } else if (message is types.ImageMessage) {
      titleLocKey = 'image_message_title';
      bodyLocKey = 'image_message_body';
      imageUrl = message.uri;
    } else if (message is types.TextMessage) {
      titleLocKey = 'text_message_title';
      body = message.text;
    }

    final notification = PushNotification(
      titleLocKey: titleLocKey,
      titleLocArgs: [user.nickname!],
      bodyLocKey: bodyLocKey,
      body: body,
      actor: user.id!,
      verb: NotificationVerb.message,
      object: widget.docId,
      message: message is types.ImageMessage ? '' : body!,
      image: imageUrl,
      uid: widget.user2.uid,
      avatar: user.avatar!,
      tokens: widget.user2.fcmTokens!.values.toList(),
    );

    final result = await GetIt.I
        .get<APIRepository>()
        .sendPushNotification(notification: notification);
    if (result) {
      loggy.debug('Push notification sent to: ${widget.user2.nickname}');
    }
  }

  Future<void> _onFileTap(types.FileMessage message) async {
    await OpenFile.open(message.uri);
  }

  Future<void> _onImageTap(types.ImageMessage message) async {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
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
        ),
      ),
    );
  }

  Future<void> _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      _onFileTap(message);
    } else if (message is types.ImageMessage) {
      _onImageTap(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserController>(context).user!;
    final isUserBlocked = widget.user2.blockedUsers!.contains(user.id!);
    final isUser2Blocked = user.blockedUsers!.contains(widget.user2.id!);

    Widget _buildBlockedText() => Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.secondary.withOpacity(.5)
                : theme.colorScheme.secondary.withOpacity(.9),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: isUser2Blocked
              ? Text(
                  l(context).youHaveBlockedThisUser,
                  style: const TextStyle(color: Colors.white),
                )
              : Text(
                  l(context).youHaveBeenBlockedByThisUser,
                  style: const TextStyle(color: Colors.white),
                ),
        );

    Future<void> _sendMessage(types.Message message) async {
      await GetIt.I.get<FirestoreService>().sendMessage(
          docID: widget.docId,
          message: ChatUtil.messageToJson(message: message));
      setState(() => _isAttachmentUploading = false);
      _sendPushNotification(user, message);
    }

    void _handleSendPressed(types.PartialText message) {
      final textMessage = types.TextMessage(
        id: uuid.v4(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: types.Status.sent,
        author: types.User(id: user.uid, imageUrl: user.avatar),
        text: message.text,
      );
      _sendMessage(textMessage);
    }

    Future<void> _handleFileSelection() async {
      final result = await FilePicker.platform.pickFiles();
      setState(() => _isAttachmentUploading = true);
      if (result != null) {
        final pickedFile = result.files.single;
        final mimeType = lookupMimeType(pickedFile.name) ?? '';
        final url = await GetIt.I.get<FirebaseStorageService>().uploadFile(
              filePath: pickedFile.path!,
              fileName: pickedFile.name,
              mimeType: mimeType,
            );
        final fileMessage = types.FileMessage(
          id: uuid.v4(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          status: types.Status.sent,
          author: types.User(id: user.uid, imageUrl: user.avatar),
          mimeType: mimeType,
          name: pickedFile.name,
          size: pickedFile.size,
          uri: url,
        );
        _sendMessage(fileMessage);
      } else {
        setState(() => _isAttachmentUploading = false);
      }
    }

    Future<void> _handleImageSelection() async {
      final pickedFile = await GetIt.I.get<ImagePickerService>().pickImage(
            imageQuality: 70,
            maxWidth: 1440,
            source: ImageSource.camera,
          );
      setState(() => _isAttachmentUploading = true);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final image = await decodeImageFromList(bytes);
        final mimeType = lookupMimeType(pickedFile.name) ?? '';
        final url = await GetIt.I.get<FirebaseStorageService>().uploadFile(
              filePath: pickedFile.path,
              fileName: pickedFile.name,
              mimeType: mimeType,
            );
        final imageMessage = types.ImageMessage(
          id: uuid.v4(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          status: types.Status.sent,
          author: types.User(id: user.uid, imageUrl: user.avatar),
          height: image.height.toDouble(),
          name: pickedFile.path.split('/').last,
          size: bytes.length,
          uri: url,
          width: image.width.toDouble(),
        );
        _sendMessage(imageMessage);
      } else {
        setState(() => _isAttachmentUploading = false);
      }
    }

    Widget _buildAttachmentBottomSheet() => SafeArea(
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
                        FontAwesomeIcons.xmark,
                        color: Color.fromRGBO(148, 148, 148, 1),
                        size: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        l(context).selectSource,
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
                title: Text(l(context).image),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
              ),
              ListTile(
                horizontalTitleGap: 0,
                leading: const Icon(Icons.description),
                title: Text(l(context).file),
                onTap: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
              ),
            ],
          ),
        );

    void _handleAttachmentPressed() {
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (context) => _buildAttachmentBottomSheet(),
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

    ChatL10n _getChatL10n() => _currentLocale == localeTurkish
        ? const ChatL10nTr()
        : const ChatL10nEn();

    ChatTheme _chatTheme(ThemeData theme) {
      final isLightMode = theme.brightness == Brightness.light;
      const defaultChatTheme = DefaultChatTheme();

      return DefaultChatTheme(
        backgroundColor: theme.backgroundColor,
        inputBackgroundColor: isLightMode
            ? theme.colorScheme.secondary
            : defaultChatTheme.inputBackgroundColor,
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
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final items = snapshot.data!.docs;

            final messages = items
                .map((e) {
                  final messageData = e.data();
                  final id = messageData['id'] as String;
                  final createdAt = messageData['createdAt'] as int;
                  final status =
                      _statusEnumMap[(messageData['status'] as String)] ??
                          types.Status.sent;
                  final author = types.User(
                    id: messageData['author']['id'] as String,
                    imageUrl: messageData['author']['id'] as String == user.uid
                        ? user.avatar!
                        : widget.user2.avatar!,
                  );
                  final type = messageData['type'] as String;
                  final previewData = messageData['previewData'] != null
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
                customBottomWidget: isUser2Blocked || isUserBlocked
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
                onTextFieldTap: _markAsSeen,
                onSendPressed: _handleSendPressed,
                user: types.User(id: user.uid, imageUrl: user.avatar),
              ),
            );
          }
        },
      ),
    );
  }
}
