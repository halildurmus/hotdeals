import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    Key? key,
    this.backgroundColor,
    required this.onPressed,
    required this.text,
    this.icon,
    this.iconSize = 20,
    this.image,
    this.fontSize = 18,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.splashColor = Colors.white30,
    this.padding = const EdgeInsets.all(8),
    this.innerPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.elevation = 2,
    this.highlightElevation = 2,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
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
    required this.icon,
    this.iconSize = 25,
    this.image,
    this.fontSize,
    this.textColor,
    this.iconColor = Colors.white,
    this.splashColor = Colors.white30,
    this.padding = const EdgeInsets.all(8),
    this.innerPadding = EdgeInsets.zero,
    this.elevation = 0,
    this.highlightElevation = 0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    this.height = 25,
    this.width = 25,
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
  final VoidCallback onPressed;
  final EdgeInsets padding, innerPadding;
  final ShapeBorder shape;
  final double elevation;
  final double highlightElevation;
  final double? height;
  final double width;
  final MaterialTapTargetSize? tapTargetSize;

  @override
  Widget build(BuildContext context) => MaterialButton(
        onPressed: onPressed,
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
        splashColor: splashColor,
        shape: shape,
        child: _getButtonChild(context),
      );

  Widget _getButtonChild(BuildContext context) {
    if (_mini) {
      return SizedBox(height: height, width: width, child: _getIconOrImage());
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null || image != null)
            Padding(padding: innerPadding, child: _getIconOrImage()),
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
    );
  }

  Widget _getIconOrImage() {
    if (icon != null) {
      return Icon(icon, size: iconSize, color: iconColor);
    }

    return image!;
  }
}
