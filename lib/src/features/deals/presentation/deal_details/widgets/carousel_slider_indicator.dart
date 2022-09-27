import 'package:flutter/material.dart';

class CarouselSliderIndicator extends StatelessWidget {
  const CarouselSliderIndicator({
    required this.currentIndex,
    required this.imageUrls,
    super.key,
  });

  final int currentIndex;
  final List<String> imageUrls;

  static const _indicatorHeight = 20.0;
  static const _indicatorDotRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _indicatorHeight / 2),
      child: SizedBox(
        height: _indicatorHeight,
        width: imageUrls.length * _indicatorDotRadius * 4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_indicatorHeight),
            color: Colors.black54,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: _indicatorDotRadius,
            children: imageUrls.map((url) {
              final index = imageUrls.indexOf(url);
              return CircleAvatar(
                backgroundColor: currentIndex == index
                    ? Colors.white
                    : const Color.fromRGBO(180, 160, 140, .5),
                radius: _indicatorDotRadius,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
