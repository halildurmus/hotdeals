import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../../../../../common_widgets/custom_snack_bar.dart';
import '../../../../../common_widgets/dialog_button.dart';
import '../../../../../helpers/context_extensions.dart';
import '../../../../auth/presentation/user_controller.dart';
import '../update_nickname_controller.dart';

class UpdateNicknameDialog extends ConsumerWidget with UiLoggy {
  const UpdateNicknameDialog({
    required this.controller,
    required this.focusNode,
    required this.formKey,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    ref.listen<AsyncValue<bool>>(updateNicknameControllerProvider,
        (prev, next) {
      if (!next.isRefreshing) {
        Navigator.of(context).pop();
        if (next.hasError) {
          const errorMessage = 'This nickname is already being used!';
          if (next.error.toString().contains(errorMessage)) {
            const CustomSnackBar.error(text: errorMessage)
                .showSnackBar(context);
          } else {
            const CustomSnackBar.error().showSnackBar(context);
          }
        } else if (next.value ?? false) {
          CustomSnackBar.success(
            text: context.l.successfullyUpdatedYourNickname,
          ).showSnackBar(context);
        }
      }
    });

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      errorMaxLines: 2,
                      labelText: context.l.nickname,
                    ),
                    focusNode: focusNode,
                    maxLength: 25,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    onChanged: (text) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.length < 5) {
                        return context.l.nicknameMustBe;
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                DialogButton(
                  onPressed: controller.text != user.nickname &&
                          (formKey.currentState?.validate() ?? false)
                      ? () => ref
                          .read(updateNicknameControllerProvider.notifier)
                          .updateNickname(user.id!, controller.text)
                      : null,
                  text: context.l.updateNickname,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
