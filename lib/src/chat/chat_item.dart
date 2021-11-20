import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/date_time_util.dart';
import 'chat.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({Key? key, required this.chat, required this.onTap})
      : super(key: key);

  final Chat chat;
  final VoidCallback onTap;

  Widget _buildBlockedText(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error, size: 18, color: Theme.of(context).errorColor),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context)!.youCannotChatWithThisUser,
          style: TextStyle(color: Theme.of(context).errorColor, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildFileText(BuildContext context) {
    final fileName = chat.lastMessage['name'] as String;

    return Row(
      children: [
        Icon(
          Icons.description,
          color: Theme.of(context).primaryColorLight,
          size: 18,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: MediaQuery.of(context).size.width * .55,
          child: Text(
            fileName,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildImageText(BuildContext context) {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.solidImage,
          color: Theme.of(context).primaryColorLight,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context)!.image,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildMessageText(BuildContext context) {
    final text = chat.lastMessage['text'] as String;

    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CachedNetworkImage(
      imageUrl: chat.user2.avatar!,
      imageBuilder: (BuildContext ctx, ImageProvider<Object> imageProvider) =>
          CircleAvatar(backgroundImage: imageProvider, radius: 24),
      placeholder: (BuildContext context, String url) =>
          const CircleAvatar(radius: 24),
    );
  }

  Widget _buildUserNickname(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .55,
      child: Text(
        chat.user2.nickname!,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _messageTextBuilder(BuildContext context) {
    if (chat.isUser1Blocked || chat.isUser2Blocked) {
      return _buildBlockedText(context);
    } else if (chat.lastMessageIsFile) {
      return _buildFileText(context);
    } else if (chat.lastMessageIsImage) {
      return _buildImageText(context);
    }

    return _buildMessageText(context);
  }

  Widget _buildMessageTime(BuildContext context) {
    return Text(
      DateTimeUtil.formatDateTime(chat.createdAt),
      style: TextStyle(
        color: chat.isRead ? Colors.grey : Theme.of(context).primaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildUnreadIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 6,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (!chat.isRead) _buildUnreadIndicator(context),
            _buildUserAvatar(),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserNickname(context),
                const SizedBox(height: 4),
                _messageTextBuilder(context),
              ],
            ),
          ],
        ),
        _buildMessageTime(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: chat.isRead ? null : theme.primaryColor.withOpacity(.1),
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
    );
  }
}
