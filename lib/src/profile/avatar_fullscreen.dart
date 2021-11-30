import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class AvatarFullScreen extends StatelessWidget {
  const AvatarFullScreen({
    Key? key,
    required this.avatarURL,
    required this.heroTag,
  }) : super(key: key);

  final String avatarURL;
  final String heroTag;

  Widget _buildImage(BuildContext ctx, ImageProvider<Object> imageProvider) {
    return PhotoView(
      backgroundDecoration: BoxDecoration(color: Theme.of(ctx).backgroundColor),
      filterQuality: FilterQuality.low,
      heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
      imageProvider: imageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CachedNetworkImage(
        imageUrl: avatarURL,
        imageBuilder: _buildImage,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
      ),
    );
  }
}
