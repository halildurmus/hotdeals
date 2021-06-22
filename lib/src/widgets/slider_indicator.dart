import 'package:flutter/material.dart';

class SliderIndicator extends StatelessWidget {
  const SliderIndicator({
    Key? key,
    required this.images,
    required this.currentIndex,
  }) : super(key: key);

  final List<String> images;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    Widget _buildDots() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: images.map((String url) {
          final int index = images.indexOf(url);

          return Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index
                  ? Colors.white
                  : const Color.fromRGBO(180, 160, 140, .5),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 2,
            ),
          );
        }).toList(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: Colors.black54,
        ),
        height: 20,
        width: images.length * 8 * 2,
        child: _buildDots(),
      ),
    );
  }
}
