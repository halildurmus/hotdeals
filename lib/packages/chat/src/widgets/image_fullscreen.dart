part of dash_chat;

class ChatImageFullScreen extends StatelessWidget {
  const ChatImageFullScreen({Key? key, required this.imageURL})
      : super(key: key);

  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              size: 20.0,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Image.network(imageURL)
        // body: Hero(
        //   tag: imageURL,
        //   child: PhotoView(
        //     imageProvider: NetworkImage(imageURL),
        //     backgroundDecoration: const BoxDecoration(color: Colors.white),
        //   ),
        // ),
        );
  }
}
