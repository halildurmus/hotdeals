import 'package:flutter/material.dart';

class SliderIndicator extends StatelessWidget {
  const SliderIndicator({
    Key? key,
    required this.images,
    required this.currentIndex,
  }) : super(key: key);

  final List<String> images;
  final int currentIndex;

  Widget buildDots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: images.map((url) {
          final index = images.indexOf(url);

          return Container(
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? Colors.white
                  : const Color.fromRGBO(180, 160, 140, .5),
              shape: BoxShape.circle,
            ),
            height: 8,
            width: 8,
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 2,
            ),
          );
        }).toList(),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.black54,
          ),
          height: 20,
          width: images.length * 8 * 2,
          child: buildDots(),
        ),
      );
}
