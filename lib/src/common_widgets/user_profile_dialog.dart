import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/hotdeals_repository.dart';
import '../features/auth/domain/my_user.dart';
import '../features/auth/presentation/user_controller.dart';
import '../features/chat/data/firestore_service.dart';
import '../features/chat/domain/chat_util.dart';
import '../helpers/context_extensions.dart';
import 'circle_avatar_shimmer.dart';
import 'error_indicator.dart';
import 'report_user_dialog.dart';

final _postedCommentAndDealCountFutureProvider =
    FutureProvider.family<List<Object?>, String>(
  (ref, userId) async => await Future.wait([
    ref
        .read(hotdealsRepositoryProvider)
        .getNumberOfCommentsPostedByUser(userId: userId),
    ref
        .read(hotdealsRepositoryProvider)
        .getNumberOfDealsPostedByUser(userId: userId),
  ]),
  name: 'PostedCommentAndDealCountFutureProvider',
);

typedef Json = Map<String, dynamic>;

class UserProfileDialog extends ConsumerWidget {
  const UserProfileDialog({
    required this.userId,
    this.showButtons = true,
    super.key,
  });

  final String userId;
  final bool showButtons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedInUser = ref.watch(userProvider)!;
    final user = ref.watch(userByIdFutureProvider(userId));
    final commentAndDealCount =
        ref.watch(_postedCommentAndDealCountFutureProvider(userId));

    if (user.isLoading || commentAndDealCount.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (user.hasError || commentAndDealCount.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: NoConnectionError(
          onPressed: () => ref
            ..refresh(userByIdFutureProvider(userId))
            ..refresh(_postedCommentAndDealCountFutureProvider(userId)),
        ),
      );
    }

    final postedCommentCount = commentAndDealCount.value![0] as int;
    final postedDealCount = commentAndDealCount.value![1] as int;
    final iconColor =
        context.isDarkMode ? Colors.grey.shade300 : context.t.primaryColor;
    final textStyle = context.textTheme.bodyText2!.copyWith(
      color: context.isDarkMode ? Colors.grey.shade400 : null,
      fontSize: 13,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l.aboutUser,
              style: context.textTheme.headline6!.copyWith(fontSize: 16),
            ),
            const Divider(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: user.value!.avatar!,
                      imageBuilder: (_, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 36,
                      ),
                      errorWidget: (_, __, ___) =>
                          const CircleAvatarShimmer(radius: 36),
                      placeholder: (_, __) =>
                          const CircleAvatarShimmer(radius: 36),
                    ),
                    const SizedBox(width: 30),
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 8,
                      children: [
                        Text(
                          user.value!.nickname!,
                          style: context.textTheme.headline6!
                              .copyWith(fontSize: 18),
                        ),
                        Row(
                          children: [
                            Icon(Icons.date_range, color: iconColor, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              context.l.joined(DateFormat.yMMM()
                                  .format(user.value!.createdAt!)),
                              style: textStyle,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.local_offer, color: iconColor, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '$postedDealCount',
                              style: textStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(context.l.dealsPosted, style: textStyle),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.chat, color: iconColor, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '$postedCommentCount',
                              style: textStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(context.l.commentsPosted, style: textStyle),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (showButtons && loggedInUser.id != user.value!.id) ...[
                  const SizedBox(height: 20),
                  _Buttons(
                    loggedInUserUid: loggedInUser.id!,
                    user2: user.value!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Buttons extends ConsumerStatefulWidget {
  _Buttons({required this.loggedInUserUid, required this.user2})
      : usersArray = ChatUtil.getUsersArray(
            user1Uid: loggedInUserUid, user2Uid: user2.uid);

  final String loggedInUserUid;
  final MyUser user2;
  final List<String> usersArray;

  @override
  ConsumerState<_Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends ConsumerState<_Buttons> {
  @override
  Widget build(BuildContext context) {
    final messageDocument =
        ref.watch(getMessageDocumentFutureProvider(widget.usersArray));
    return messageDocument.maybeWhen(
      data: (data) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) =>
                    ReportUserDialog(userId: widget.user2.id!),
              ).then((_) => Navigator.of(context).pop()),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.secondary,
              ),
              child: Text(context.l.reportUser, textAlign: TextAlign.center),
            ),
            ElevatedButton(
              onPressed: () async {
                if (data.docs.isEmpty) {
                  await ref
                      .read(firestoreServiceProvider)
                      .createMessageDocument(
                          user1Uid: widget.loggedInUserUid,
                          user2Uid: widget.user2.uid);
                }

                final conversationId = ChatUtil.getConversationID(
                    user1Uid: widget.loggedInUserUid,
                    user2Uid: widget.user2.uid);
                if (!mounted) return;
                context.go('/chats/$conversationId', extra: widget.user2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.secondary,
              ),
              child: Text(context.l.sendMessage, textAlign: TextAlign.center),
            ),
          ],
        );
      },
      orElse: () => const SizedBox(),
    );
  }
}
