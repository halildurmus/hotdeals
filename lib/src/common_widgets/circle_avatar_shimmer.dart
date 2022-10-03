import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../helpers/context_extensions.dart';

class CircleAvatarShimmer extends StatelessWidget {
  const CircleAvatarShimmer({this.radius, super.key});

  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:
          context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor:
          context.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade100,
      child: CircleAvatar(radius: radius),
    );
  }
}
