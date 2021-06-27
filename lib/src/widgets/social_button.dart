import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    Key? key,
    this.backgroundColor,
    required this.onPressed,
    required this.text,
    this.icon,
    this.iconSize = 20.0,
    this.image,
    this.fontSize = 18.0,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.splashColor = Colors.white30,
    this.padding = const EdgeInsets.all(8.0),
    this.innerPadding = const EdgeInsets.symmetric(
      horizontal: 6.0,
    ),
    this.elevation = 2.0,
    this.highlightElevation = 2.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(24.0),
      ),
    ),
    this.height,
    this.width = double.infinity,
    this.tapTargetSize,
  })  : _mini = false,
        super(key: key);

  const SocialButton.mini({
    Key? key,
    this.backgroundColor,
    required this.onPressed,
    this.text,
    @required this.icon,
    this.iconSize = 25.0,
    this.image,
    this.fontSize,
    this.textColor,
    this.iconColor = Colors.white,
    this.splashColor = Colors.white30,
    this.padding = const EdgeInsets.all(8.0),
    this.innerPadding = EdgeInsets.zero,
    this.elevation = 0.0,
    this.highlightElevation = 0.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(24.0),
      ),
    ),
    this.height = 25.0,
    this.width = 25.0,
    this.tapTargetSize = MaterialTapTargetSize.shrinkWrap,
  })  : _mini = true,
        super(key: key);

  final bool _mini;
  final IconData? icon;
  final double iconSize;
  final Widget? image;
  final String? text;
  final double? fontSize;
  final Color? textColor, iconColor, backgroundColor, splashColor;
  final void Function() onPressed;
  final EdgeInsets padding, innerPadding;
  final ShapeBorder shape;
  final double elevation;
  final double highlightElevation;
  final double? height;
  final double width;
  final MaterialTapTargetSize? tapTargetSize;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: backgroundColor!.withOpacity(.5),
      disabledElevation: elevation,
      materialTapTargetSize: _mini ? tapTargetSize : null,
      key: key,
      minWidth: _mini ? width : null,
      height: height,
      elevation: elevation,
      highlightElevation: highlightElevation,
      padding: padding,
      color: backgroundColor,
      onPressed: onPressed,
      splashColor: splashColor,
      shape: shape,
      child: _getButtonChild(context),
    );
  }

  /// Get the inner content of a button
  Widget _getButtonChild(BuildContext context) {
    if (_mini) {
      return SizedBox(
        height: height,
        width: width,
        child: _getIconOrImage(),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: innerPadding,
              child: _getIconOrImage(),
            ),
            Text(
              text!,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the icon or image widget
  Widget _getIconOrImage() {
    if (image != null) {
      return image!;
    } else if (icon != null) {
      return Icon(icon, size: iconSize, color: iconColor);
    }

    return const SizedBox();
  }
}
