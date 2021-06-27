part of dash_chat;

/// Avatar container for the the chat view uses a [CircleAvatar]
/// widget as default which can be overridden by providing
/// [avatarBuilder] property
class AvatarContainer extends StatelessWidget {
  const AvatarContainer({
    required this.userId,
    this.onPress,
    this.onLongPress,
    this.avatarBuilder,
    this.constraints,
    this.avatarMaxSize,
  });

  /// A [String] used to get the url of the user
  /// avatar
  final String userId;

  /// [onPress] function takes a function with this structure
  /// [Function(ChatUser)] will trigger when the avatar
  /// is tapped on
  final Function(String)? onPress;

  /// [onLongPress] function takes a function with this structure
  /// [Function(ChatUser)] will trigger when the avatar
  /// is long pressed
  final Function(String)? onLongPress;

  /// [avatarBuilder] function takes a function with this structure
  /// [Widget Function(ChatUser)] to build the avatar
  final Widget Function(String)? avatarBuilder;

  /// [constraints] to apply to build the layout
  /// by default used MediaQuery and take screen size as constraints
  final BoxConstraints? constraints;

  final double? avatarMaxSize;

  @override
  Widget build(BuildContext context) {
    final BoxConstraints constraints = this.constraints ??
        BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
        );

    return GestureDetector(
      onTap: () => onPress?.call(userId),
      onLongPress: () => onLongPress?.call(userId),
      child: avatarBuilder != null
          ? avatarBuilder!(userId)
          : Center(
              child: ClipOval(
                child: FadeInImage.memoryNetwork(
                  image:
                      'https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg',
                  placeholder: kTransparentImage,
                  fit: BoxFit.cover,
                  height: constraints.maxWidth * 0.10,
                  width: constraints.maxWidth * 0.10,
                ),
              ),
            ),
    );
  }
}
