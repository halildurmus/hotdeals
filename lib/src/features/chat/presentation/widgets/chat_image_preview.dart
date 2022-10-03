import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../helpers/context_extensions.dart';

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
        title: Text(fileName),
      ),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(color: context.t.backgroundColor),
        filterQuality: FilterQuality.low,
        imageProvider: NetworkImage(imageUri),
      ),
    );
  }
}
