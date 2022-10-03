import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../../helpers/context_extensions.dart';
import 'carousel_slider_indicator.dart';

class DealImagesFullScreen extends StatefulWidget {
  const DealImagesFullScreen({
    required this.currentIndex,
    required this.imageUrls,
    super.key,
  });

  final int currentIndex;
  final List<String> imageUrls;

  @override
  State<DealImagesFullScreen> createState() => _DealImagesFullScreen();
}

class _DealImagesFullScreen extends State<DealImagesFullScreen> {
  late int currentIndex;
  late List<String> imageUrls;

  @override
  void initState() {
    currentIndex = widget.currentIndex;
    imageUrls = widget.imageUrls;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            items: imageUrls
                .map(
                  (url) => PhotoView(
                    imageProvider: NetworkImage(url),
                    backgroundDecoration:
                        BoxDecoration(color: context.t.backgroundColor),
                  ),
                )
                .toList(),
            options: CarouselOptions(
              viewportFraction: 1,
              height: double.infinity,
              enlargeCenterPage: true,
              initialPage: currentIndex,
              onPageChanged: (i, reason) => setState(() => currentIndex = i),
            ),
          ),
          if (imageUrls.length > 1)
            CarouselSliderIndicator(
              imageUrls: imageUrls,
              currentIndex: currentIndex,
            ),
        ],
      ),
    );
  }
}
