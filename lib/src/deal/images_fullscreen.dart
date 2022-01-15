import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';

import '../widgets/slider_indicator.dart';

class DealImagesFullScreen extends StatefulWidget {
  const DealImagesFullScreen({
    required this.currentIndex,
    required this.images,
    Key? key,
  }) : super(key: key);

  final int currentIndex;
  final List<String> images;

  @override
  _DealImagesFullScreen createState() => _DealImagesFullScreen();
}

class _DealImagesFullScreen extends State<DealImagesFullScreen> {
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
    final theme = Theme.of(context);
    final List<Widget> items = widget.images
        .map((item) => PhotoView(
              imageProvider: NetworkImage(item),
              backgroundDecoration: BoxDecoration(color: theme.backgroundColor),
            ))
        .toList();

    Widget buildBackButton() => SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 20),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(FontAwesomeIcons.times),
              iconSize: 20,
            ),
          ),
        );

    Widget buildSlider() => CarouselSlider(
          items: items,
          options: CarouselOptions(
            viewportFraction: 1,
            height: double.infinity,
            enlargeCenterPage: true,
            initialPage: currentIndex,
            onPageChanged: (i, reason) => setState(() => currentIndex = i),
          ),
        );

    Widget buildSliderIndicator() =>
        SliderIndicator(images: images, currentIndex: currentIndex);

    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              buildSlider(),
              if (images.length > 1) buildSliderIndicator(),
            ],
          ),
          buildBackButton(),
        ],
      ),
    );
  }
}
