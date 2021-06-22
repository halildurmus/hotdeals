import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirestoreImage extends StatefulWidget {
  FirestoreImage({
    required this.reference,
    required this.fallback,
    required this.placeholder,
  });

  final Reference reference;
  final Widget fallback;
  final ImageProvider placeholder;

  @override
  FirestoreImageState createState() =>
      FirestoreImageState(reference, fallback, placeholder);
}

class FirestoreImageState extends State<FirestoreImage> {
  FirestoreImageState(Reference reference, this.fallback, this.placeholder) {
    reference
        .getDownloadURL()
        .then(_setImageData)
        .catchError((error, stackTrace) {
      _setError();
      //Catcher.reportCheckedError(error, stackTrace);
      print(stackTrace);
    });
  }

  final Widget fallback;
  final ImageProvider placeholder;

  late String _imageUrl;
  bool _loaded = false;

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
    if (_loaded) {
      return FadeInImage(
          image: NetworkImage(_imageUrl),
          placeholder: placeholder,
          fit: BoxFit.fitWidth);
    } else {
      return fallback;
    }
  }
}
