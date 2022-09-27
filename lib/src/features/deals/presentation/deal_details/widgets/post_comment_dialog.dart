import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../common_widgets/custom_snack_bar.dart';
import '../../../../../common_widgets/dialog_button.dart';
import '../../../../../common_widgets/loading_dialog.dart';
import '../../../../../helpers/context_extensions.dart';
import '../../../../auth/presentation/user_controller.dart';
import '../../../domain/deal.dart';
import '../post_comment_dialog_controller.dart';

class PostCommentDialog extends ConsumerStatefulWidget {
  const PostCommentDialog({required this.deal, super.key});

  final Deal deal;

  @override
  ConsumerState<PostCommentDialog> createState() => _PostCommentState();
}

class _PostCommentState extends ConsumerState<PostCommentDialog> {
  @override
  void initState() {
    ref.read(postCommentDialogControllerProvider).focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(postCommentDialogControllerProvider);
    final user = ref.watch(userProvider)!;

    Future<void> postComment() async {
      if (controller.textController.text.isEmpty) return;
      unawaited(ref.read(loadingDialogProvider).showLoadingDialog(context));
      await controller.postComment(
        deal: widget.deal,
        poster: user,
        onSuccess: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the PostCommentDialog.
          CustomSnackBar.success(text: context.l.postedYourComment)
              .showSnackBar(context);
        },
        onFailure: () {
          Navigator.of(context)
            ..pop() // Pops the loading dialog.
            ..pop(); // Pops the PostCommentDialog.
          const CustomSnackBar.error().showSnackBar(context);
        },
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l.postAComment, style: context.textTheme.headline6),
            const SizedBox(height: 20),
            Form(
              key: controller.formKey,
              child: TextFormField(
                controller: controller.textController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorMaxLines: 2,
                  hintStyle: context.textTheme.bodyText2!.copyWith(
                      color:
                          context.isLightMode ? Colors.black54 : Colors.grey),
                  hintText: context.l.enterYourComment,
                ),
                focusNode: controller.focusNode,
                minLines: 4,
                maxLines: 30,
                maxLength: 500,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                onChanged: (text) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l.nicknameMustBe;
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            DialogButton(
              onPressed: (controller.formKey.currentState?.validate() ?? false)
                  ? postComment
                  : null,
              text: context.l.postComment,
            ),
          ],
        ),
      ),
    );
  }
}
