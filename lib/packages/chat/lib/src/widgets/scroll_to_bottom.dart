part of dash_chat;

class ScrollToBottom extends StatelessWidget {
  const ScrollToBottom({
    this.onScrollToBottomPress,
    required this.scrollController,
    required this.inverted,
    required this.scrollToBottomStyle,
  });

  final Function? onScrollToBottomPress;
  final ScrollController scrollController;
  final bool inverted;
  final ScrollToBottomStyle scrollToBottomStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: scrollToBottomStyle.width,
      height: scrollToBottomStyle.height,
      child: RawMaterialButton(
        elevation: 5,
        fillColor: scrollToBottomStyle.backgroundColor ??
            Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        child: Icon(
          scrollToBottomStyle.icon ?? Icons.keyboard_arrow_down,
          color: scrollToBottomStyle.textColor ?? Colors.white,
        ),
        onPressed: () {
          if (onScrollToBottomPress != null) {
            onScrollToBottomPress!();
          } else {
            scrollController.animateTo(
              inverted ? 0.0 : scrollController.position.maxScrollExtent + 25.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    );
  }
}
