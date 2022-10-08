import 'dart:async';
import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/firebase_storage_service.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../core/image_picker_service.dart';
import '../../../helpers/context_extensions.dart';
import '../../auth/domain/my_user.dart';
import '../../auth/presentation/user_controller.dart';
import '../../notifications/domain/push_notification.dart';
import '../data/firestore_service.dart';
import '../domain/chat_util.dart';
import 'widgets/message_app_bar.dart';

typedef Json = Map<String, dynamic>;

const _statusEnumMap = <String, types.Status>{
  'delivered': types.Status.delivered,
  'error': types.Status.error,
  'seen': types.Status.seen,
  'sending': types.Status.sending,
  'sent': types.Status.sent
};

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({required this.docId, required this.user2, super.key});

  final String docId;
  final MyUser user2;

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> with UiLoggy {
  var isAttachmentUploading = false;
  final uuid = const Uuid();

  @override
  void initState() {
    markAsSeen();
    super.initState();
  }

  Future<void> markAsSeen() async => await ref
      .read(firestoreServiceProvider)
      .markMessagesAsSeen(docID: widget.docId, user2Uid: widget.user2.uid);

  Future<void> sendPushNotification(MyUser user, types.Message message) async {
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

    final result = await AsyncValue.guard(() => ref
        .read(hotdealsRepositoryProvider)
        .sendPushNotification(notification: notification));
    result.maybeWhen(
      data: (_) =>
          loggy.info('Push notification sent to: ${widget.user2.nickname}'),
      orElse: () => loggy.error(
          'Push notification failed to send to: ${widget.user2.nickname}'),
    );
  }

  Future<String> saveFile(String fileURL, String messageID) async {
    final reference =
        ref.read(firebaseStorageServiceProvider).refFromURL(url: fileURL);
    final bytes = await reference.getData();

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/${reference.name}';
    await File(filePath).writeAsBytes(bytes!);

    return filePath;
  }

  Future<void> onFileTap(types.FileMessage message) async {
    final filePath = await saveFile(message.uri, message.id);
    await OpenFile.open(filePath);
  }

  Future<void> onImageTap(types.ImageMessage message) async => context.go(
        '/chats/${widget.docId}/images/${message.id}?name=${message.name}&uri=${Uri.encodeComponent(message.uri)}',
        extra: widget.user2,
      );

  Future<void> handleMessageTap(
      BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      await onFileTap(message);
    } else if (message is types.ImageMessage) {
      await onImageTap(message);
    }
  }

  ChatL10n get chatL10n {
    switch (context.locale.languageCode) {
      case 'tr':
        return const ChatL10nTr();
      default:
        return const ChatL10nEn();
    }
  }

  ChatTheme get chatTheme {
    final theme = context.t;
    const defaultChatTheme = DefaultChatTheme();
    return DefaultChatTheme(
      backgroundColor: theme.backgroundColor,
      inputBackgroundColor: context.isLightMode
          ? theme.colorScheme.secondary
          : defaultChatTheme.inputBackgroundColor,
      inputTextDecoration: defaultChatTheme.inputTextDecoration.copyWith(
        fillColor: Colors.transparent,
      ),
      primaryColor:
          context.isLightMode ? theme.primaryColor : theme.primaryColorDark,
      secondaryColor: context.isLightMode
          ? theme.primaryColorLight.withOpacity(.2)
          : theme.primaryColorLight.withOpacity(.1),
      receivedMessageBodyTextStyle: context.textTheme.bodyText2!.copyWith(
        color: context.isLightMode ? null : Colors.white,
        height: 1.3,
        fontSize: 15,
      ),
      receivedMessageLinkDescriptionTextStyle:
          defaultChatTheme.receivedMessageLinkDescriptionTextStyle.copyWith(
        color: context.isLightMode ? null : Colors.white,
      ),
      receivedMessageLinkTitleTextStyle:
          defaultChatTheme.receivedMessageLinkTitleTextStyle.copyWith(
        color: context.isLightMode ? null : Colors.white,
      ),
      sentMessageBodyTextStyle: context.textTheme.bodyText2!.copyWith(
        color: Colors.white,
        height: 1.3,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isUserBlocked = widget.user2.blockedUsers!.contains(user.id!);
    final isUser2Blocked = user.blockedUsers!.contains(widget.user2.id!);

    Future<void> sendMessage(types.Message message) async {
      await ref.read(firestoreServiceProvider).sendMessage(
          docID: widget.docId,
          message: ChatUtil.messageToJson(message: message));
      setState(() => isAttachmentUploading = false);
      await sendPushNotification(user, message);
    }

    void handleSendPressed(types.PartialText message) {
      final textMessage = types.TextMessage(
        id: uuid.v4(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: types.Status.sent,
        author: types.User(id: user.uid, imageUrl: user.avatar),
        text: message.text,
      );
      sendMessage(textMessage);
    }

    Future<void> handleFileSelection() async {
      final result = await FilePicker.platform.pickFiles();
      setState(() => isAttachmentUploading = true);
      if (result != null) {
        final pickedFile = result.files.single;
        final mimeType = lookupMimeType(pickedFile.name) ?? '';
        final url = await ref.read(firebaseStorageServiceProvider).uploadFile(
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
        await sendMessage(fileMessage);
      } else {
        setState(() => isAttachmentUploading = false);
      }
    }

    Future<void> handleImageSelection() async {
      final pickedFile = await ref.read(imagePickerServiceProvider).pickImage(
            imageQuality: 70,
            maxWidth: 1440,
            source: ImageSource.camera,
          );
      setState(() => isAttachmentUploading = true);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final image = await decodeImageFromList(bytes);
        final mimeType = lookupMimeType(pickedFile.name) ?? '';
        final url = await ref.read(firebaseStorageServiceProvider).uploadFile(
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
        await sendMessage(imageMessage);
      } else {
        setState(() => isAttachmentUploading = false);
      }
    }

    Widget buildAttachmentBottomSheet() {
      return SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: context.pop,
                    child: const Icon(
                      FontAwesomeIcons.xmark,
                      color: Color.fromRGBO(148, 148, 148, 1),
                      size: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      context.l.selectSource,
                      textAlign: TextAlign.center,
                      style: context.textTheme.subtitle1!.copyWith(
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
              title: Text(context.l.image),
              onTap: () {
                Navigator.pop(context);
                handleImageSelection();
              },
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.description),
              title: Text(context.l.file),
              onTap: () {
                Navigator.pop(context);
                handleFileSelection();
              },
            ),
          ],
        ),
      );
    }

    void handleAttachmentPressed() {
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (context) => buildAttachmentBottomSheet(),
      );
    }

    Future<void> handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
    ) async {
      await ref.read(firestoreServiceProvider).updateMessagePreview(
            docID: widget.docId,
            messageID: message.id,
            previewData: previewData.toJson(),
          );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MessageAppBar(user2: widget.user2),
      ),
      body: StreamBuilder<QuerySnapshot<Json>>(
        stream: ref
            .read(firestoreServiceProvider)
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
                    ? _BlockedText(isUser2Blocked)
                    : null,
                dateLocale: context.locale.languageCode,
                disableImageGallery: true,
                inputOptions: InputOptions(onTextFieldTap: markAsSeen),
                isAttachmentUploading: isAttachmentUploading,
                l10n: chatL10n,
                messages: messages,
                onAttachmentPressed: handleAttachmentPressed,
                onMessageTap: handleMessageTap,
                onPreviewDataFetched: handlePreviewDataFetched,
                onSendPressed: handleSendPressed,
                showUserAvatars: true,
                theme: chatTheme,
                user: types.User(id: user.uid, imageUrl: user.avatar),
              ),
            );
          }
        },
      ),
    );
  }
}

class _BlockedText extends StatelessWidget {
  const _BlockedText(this.isUser2Blocked);

  final bool isUser2Blocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.isDarkMode
            ? context.colorScheme.secondary.withOpacity(.5)
            : context.colorScheme.secondary.withOpacity(.9),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: isUser2Blocked
          ? Text(
              context.l.youHaveBlockedThisUser,
              style: const TextStyle(color: Colors.white),
            )
          : Text(
              context.l.youHaveBeenBlockedByThisUser,
              style: const TextStyle(color: Colors.white),
            ),
    );
  }
}
