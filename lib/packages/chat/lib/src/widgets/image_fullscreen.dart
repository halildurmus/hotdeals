part of dash_chat;

class ChatImageFullScreen extends StatelessWidget {
  const ChatImageFullScreen({required this.imageURL});

  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            color: const Color.fromRGBO(148, 148, 148, 1),
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              color: Color.fromRGBO(148, 148, 148, 1),
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
