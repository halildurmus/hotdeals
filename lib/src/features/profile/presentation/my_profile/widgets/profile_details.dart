import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../common_widgets/circle_avatar_shimmer.dart';
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
            child: CachedNetworkImage(
              imageUrl: user.avatar!,
              imageBuilder: (_, imageProvider) => CircleAvatar(
                backgroundImage: imageProvider,
                radius: 50,
              ),
              errorWidget: (_, __, ___) =>
                  const CircleAvatarShimmer(radius: 50),
              placeholder: (_, __) => const CircleAvatarShimmer(radius: 50),
            ),
          ),
          Wrap(
            direction: Axis.vertical,
            spacing: 5,
            children: [
              Text(user.nickname!, style: context.textTheme.titleLarge),
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
