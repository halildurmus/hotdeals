import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
        ),
      ),
      body: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (ctx, imageProvider) => PhotoView(
          backgroundDecoration: BoxDecoration(
            color: Theme.of(ctx).backgroundColor,
          ),
          filterQuality: FilterQuality.low,
          imageProvider: imageProvider,
        ),
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.error)),
      ),
    );
  }
}
