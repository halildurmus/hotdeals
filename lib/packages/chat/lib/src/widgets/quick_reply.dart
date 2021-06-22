part of dash_chat;

class QuickReply extends StatelessWidget {
  const QuickReply({
    this.quickReplyBuilder,
    this.quickReplyStyle,
    this.quickReplyTextStyle,
    this.constraints,
    this.onReply,
    required this.reply,
  });

  final Reply reply;

  final Function(Reply)? onReply;

  final BoxDecoration? quickReplyStyle;

  final TextStyle? quickReplyTextStyle;

  final Widget Function(Reply)? quickReplyBuilder;

  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BoxConstraints constraints = this.constraints ??
        BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
        );
    return GestureDetector(
      onTap: () {
        onReply!(reply);
      },
      child: quickReplyBuilder != null
          ? quickReplyBuilder!(reply)
          : Container(
              margin: const EdgeInsets.only(
                  left: 5.0, right: 5.0, top: 5.0, bottom: 10.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              decoration: quickReplyStyle ??
                  BoxDecoration(
                    border: Border.all(width: 1.0, color: theme.accentColor),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
              constraints: BoxConstraints(maxWidth: constraints.maxWidth / 3),
              child: Text(
                reply.title,
                style: quickReplyTextStyle ??
                    TextStyle(
                      color: theme.accentColor,
                      fontSize: 12.0,
                    ),
              ),
            ),
    );
  }
}
