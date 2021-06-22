import 'package:flutter/material.dart';

class AvatarFullScreen extends StatelessWidget {
  const AvatarFullScreen({Key? key, required this.avatarURL}) : super(key: key);

  final String avatarURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(
          avatarURL,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
