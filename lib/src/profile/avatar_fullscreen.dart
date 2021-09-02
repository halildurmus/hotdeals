import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class AvatarFullScreen extends StatelessWidget {
  const AvatarFullScreen({Key? key, required this.avatarURL}) : super(key: key);

  final String avatarURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        imageProvider: NetworkImage(avatarURL),
        backgroundDecoration:
            BoxDecoration(color: Theme.of(context).backgroundColor),
      ),
    );
  }
}
