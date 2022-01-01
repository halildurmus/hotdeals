import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageFullScreen extends StatelessWidget {
  const ImageFullScreen({
    Key? key,
    this.heroTag,
    required this.imageUrl,
  }) : super(key: key);

  final String? heroTag;
  final String imageUrl;

  Widget _buildImage(BuildContext ctx, ImageProvider<Object> imageProvider) =>
      PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Theme.of(ctx).backgroundColor,
        ),
        filterQuality: FilterQuality.low,
        heroAttributes:
            heroTag != null ? PhotoViewHeroAttributes(tag: heroTag!) : null,
        imageProvider: imageProvider,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: _buildImage,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.error)),
        ),
      );
}
