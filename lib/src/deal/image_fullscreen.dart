import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';

import '../widgets/slider_indicator.dart';

class ImageFullScreen extends StatefulWidget {
  const ImageFullScreen({
    Key? key,
    required this.images,
    required this.currentIndex,
  }) : super(key: key);

  final List<String> images;
  final int currentIndex;

  @override
  _MyImageScreen createState() => _MyImageScreen();
}

class _MyImageScreen extends State<ImageFullScreen> {
  late int currentIndex;
  late List<String> images;

  @override
  void initState() {
    currentIndex = widget.currentIndex;
    images = widget.images;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> items = widget.images.map((String item) {
      return PhotoView(
        imageProvider: NetworkImage(item),
        backgroundDecoration: BoxDecoration(color: theme.backgroundColor),
      );
    }).toList();

    Widget buildBackButton() {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 20),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(FontAwesomeIcons.times),
            iconSize: 20,
          ),
        ),
      );
    }

    Widget buildSlider() {
      return CarouselSlider(
        items: items,
        options: CarouselOptions(
          viewportFraction: 1.0,
          height: double.infinity,
          enlargeCenterPage: true,
          initialPage: currentIndex,
          onPageChanged: (int i, CarouselPageChangedReason reason) {
            setState(() {
              currentIndex = i;
            });
          },
        ),
      );
    }

    Widget buildSliderIndicator() {
      return SliderIndicator(images: images, currentIndex: currentIndex);
    }

    Widget buildBody() {
      return Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              buildSlider(),
              if (images.length > 1) buildSliderIndicator(),
            ],
          ),
          buildBackButton(),
        ],
      );
    }

    return Scaffold(
      body: buildBody(),
    );
  }
}
