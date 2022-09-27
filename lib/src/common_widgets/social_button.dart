import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    required this.height,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
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
    this.width = double.infinity,
    this.tapTargetSize,
    super.key,
  }) : _mini = false;

  const SocialButton.facebook({
    required this.onPressed,
    required this.text,
    super.key,
    this.backgroundColor = const Color.fromRGBO(63, 91, 150, 1),
    this.icon = FontAwesomeIcons.facebook,
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
    this.height = 48,
    this.width = double.infinity,
    this.tapTargetSize,
  }) : _mini = false;

  const SocialButton.google({
    required this.onPressed,
    required this.text,
    super.key,
    this.backgroundColor = const Color.fromRGBO(66, 133, 244, 1),
    this.icon = FontAwesomeIcons.google,
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
    this.height = 48,
    this.width = double.infinity,
    this.tapTargetSize,
  }) : _mini = false;

  const SocialButton.mini({
    required this.onPressed,
    required this.icon,
    super.key,
    this.backgroundColor,
    this.text,
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
  }) : _mini = true;

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
  Widget build(BuildContext context) {
    return MaterialButton(
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
  }

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

  Widget _getIconOrImage() =>
      icon != null ? Icon(icon, color: iconColor, size: iconSize) : image!;
}
