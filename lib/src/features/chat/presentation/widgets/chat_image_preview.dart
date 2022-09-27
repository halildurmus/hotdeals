import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class ChatImagePreview extends StatelessWidget {
  const ChatImagePreview({
    required this.fileName,
    required this.imageUri,
    super.key,
  });

  final String fileName;
  final String imageUri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(fileName),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
        ),
      ),
      body: PhotoView(
        backgroundDecoration:
            BoxDecoration(color: Theme.of(context).backgroundColor),
        filterQuality: FilterQuality.low,
        imageProvider: NetworkImage(imageUri),
      ),
    );
  }
}
