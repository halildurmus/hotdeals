import 'package:flutter/widgets.dart';

class GrayscaleColorFiltered extends StatelessWidget {
  const GrayscaleColorFiltered({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  static const _grayscale = ColorFilter.matrix(
    <double>[
      0.2126, 0.7152, 0.0722, 0, 0, //
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ],
  );

  @override
  Widget build(BuildContext context) => ColorFiltered(
        colorFilter: _grayscale,
        child: child,
      );
}
