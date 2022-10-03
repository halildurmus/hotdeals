import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../helpers/context_extensions.dart';

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (_, imageProvider) => PhotoView(
            backgroundDecoration:
                BoxDecoration(color: context.t.backgroundColor),
            filterQuality: FilterQuality.low,
            imageProvider: imageProvider,
          ),
        errorWidget: (_, __, ___) => Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error),
              const SizedBox(width: 4),
              Text(context.l.anErrorOccurred),
            ],
          ),
        ),
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: CircularProgressIndicator(value: progress.progress),
        ),
      ),
    );
  }
}
