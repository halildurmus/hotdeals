import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirestoreImage extends StatefulWidget {
  const FirestoreImage({
    required this.reference,
    required this.fallback,
    required this.placeholder,
    super.key,
  });

  final Reference reference;
  final Widget fallback;
  final ImageProvider placeholder;

  @override
  State<FirestoreImage> createState() => _FirestoreImageState();
}

class _FirestoreImageState extends State<FirestoreImage> {
  late String _imageUrl;
  bool _loaded = false;

  @override
  void initState() {
    widget.reference
        .getDownloadURL()
        .then(_setImageData)
        .catchError((error, stackTrace) {
      _setError();
    });
    super.initState();
  }

  void _setImageData(dynamic url) {
    setState(() {
      _loaded = true;
      _imageUrl = url;
    });
  }

  void _setError() {
    setState(() {
      _loaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loaded
        ? FadeInImage(
            fit: BoxFit.fitWidth,
            image: NetworkImage(_imageUrl),
            placeholder: widget.placeholder,
          )
        : widget.fallback;
  }
}
