import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../common_widgets/circle_avatar_shimmer.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../../helpers/date_time_helper.dart';
import '../../../settings/presentation/locale_controller.dart';
import '../../domain/chat.dart';

class ChatItem extends ConsumerWidget {
  const ChatItem({required this.chat, required this.onTap, super.key});

  final Chat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    return ListTile(
      onTap: onTap,
      tileColor: chat.lastMessageIsRead
          ? null
          : context.t.primaryColor.withOpacity(.1),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!chat.lastMessageIsRead)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundColor: context.t.primaryColor,
                radius: 6,
              ),
            ),
          CachedNetworkImage(
            imageUrl: chat.user2.avatar!,
            imageBuilder: (_, imageProvider) =>
                CircleAvatar(backgroundImage: imageProvider),
            errorWidget: (_, __, ___) => const CircleAvatarShimmer(),
            placeholder: (_, __) => const CircleAvatarShimmer(),
          ),
        ],
      ),
      title: Text(
        chat.user2.nickname!,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: _MessageText(chat: chat),
      trailing: Text(
        formatDateTime(chat.createdAt, locale: locale),
        style: TextStyle(
          color: chat.lastMessageIsRead ? Colors.grey : context.t.primaryColor,
        ),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  const _MessageText({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    if (chat.user1IsBlocked || chat.user2IsBlocked) {
      return Row(
        children: [
          Icon(Icons.error, color: context.t.errorColor, size: 16),
          const SizedBox(width: 4),
          Text(
            context.l.youCannotChatWithThisUser,
            style: TextStyle(color: context.t.errorColor),
          ),
        ],
      );
    }

    switch (chat.lastMessageType) {
      case types.MessageType.file:
        final fileName = chat.lastMessage['name'] as String;
        return Row(
          children: [
            const Icon(Icons.description, size: 16),
            const SizedBox(width: 4),
            Text(fileName, overflow: TextOverflow.ellipsis),
          ],
        );
      case types.MessageType.image:
        return Row(
          children: [
            const Icon(FontAwesomeIcons.solidImage, size: 14),
            const SizedBox(width: 4),
            Text(context.l.image),
          ],
        );
      default:
        final text = chat.lastMessage['text'] as String;
        return Text(text, overflow: TextOverflow.ellipsis);
    }
  }
}
