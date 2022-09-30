import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../helpers/context_extensions.dart';
import '../../../../auth/domain/my_user.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({required this.user, super.key});

  final MyUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 25,
        children: [
          GestureDetector(
            onTap: () =>
                context.go('/image?url=${Uri.encodeComponent(user.avatar!)}'),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar!),
              radius: 50,
            ),
          ),
          Wrap(
            direction: Axis.vertical,
            spacing: 5,
            children: [
              Text(user.nickname!, style: context.textTheme.headline6),
              Text(user.email!, style: context.textTheme.caption),
              OutlinedButton(
                onPressed: () => context.go('/update-profile'),
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromWidth(150),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(context.l.updateProfile),
              )
            ],
          ),
        ],
      ),
    );
  }
}