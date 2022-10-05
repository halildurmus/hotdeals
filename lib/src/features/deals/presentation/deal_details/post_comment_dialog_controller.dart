import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/hotdeals_api.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../auth/domain/my_user.dart';
import '../../../notifications/domain/push_notification.dart';
import '../../domain/comment.dart';
import '../../domain/deal.dart';

final postCommentDialogControllerProvider =
    Provider.autoDispose<PostCommentDialogController>((ref) {
  final focusNode = FocusNode();
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  ref.onDispose(() {
    focusNode.dispose();
    textController.dispose();
  });

  return PostCommentDialogController(
      ref.read, focusNode, formKey, textController);
}, name: 'PostCommentDialogControllerProvider');

class PostCommentDialogController with NetworkLoggy {
  PostCommentDialogController(
    Reader read,
    this.focusNode,
    this.formKey,
    this.textController,
  ) : _hotdealsRepository = read(hotdealsRepositoryProvider);

  final HotdealsApi _hotdealsRepository;
  FocusNode focusNode;
  GlobalKey<FormState> formKey;
  TextEditingController textController;

  Future<void> _sendPushNotification({
    required Comment comment,
    required Deal deal,
  }) async {
    final poster =
        await _hotdealsRepository.getUserExtendedById(id: deal.postedBy!);
    final notification = PushNotification(
      titleLocKey: 'comment_title',
      titleLocArgs: [poster.nickname!],
      body: comment.message,
      actor: poster.id!,
      verb: NotificationVerb.comment,
      object: deal.id!,
      message: comment.message,
      uid: poster.uid,
      avatar: poster.avatar!,
      tokens: poster.fcmTokens!.values.toList(),
    );
    final result = await AsyncValue.guard(() =>
        _hotdealsRepository.sendPushNotification(notification: notification));
    result.maybeWhen(
      data: (_) => loggy.info('Push notification sent to: ${poster.nickname}'),
      orElse: () => loggy
          .error('Push notification failed to sent to: ${poster.nickname}'),
    );
  }

  Future<void> postComment({
    required Deal deal,
    required MyUser poster,
    required VoidCallback onFailure,
    required VoidCallback onSuccess,
  }) async {
    final comment = Comment(message: textController.text);
    final result = await AsyncValue.guard(() =>
        _hotdealsRepository.postComment(dealId: deal.id!, comment: comment));
    result.maybeWhen(
      data: (data) async {
        // Send push notification to the poster if the commentator is not
        // the poster.
        if (poster.id! != deal.postedBy!) {
          await _sendPushNotification(comment: data, deal: deal);
        }
        onSuccess();
      },
      orElse: onFailure,
    );
  }
}
