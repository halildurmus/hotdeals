part of dash_chat;

class ChatInputToolbar extends StatelessWidget {
  const ChatInputToolbar({
    Key? key,
    required this.onTap,
    this.textDirection = TextDirection.ltr,
    this.focusNode,
    this.scrollController,
    this.text,
    this.textInputAction,
    this.sendOnEnter = false,
    this.onTextChange,
    this.inputDisabled = false,
    this.controller,
    this.leading = const <Widget>[],
    this.trailing = const <Widget>[],
    this.inputDecoration,
    this.textCapitalization,
    this.inputTextStyle,
    this.inputContainerStyle,
    this.inputMaxLines = 1,
    this.showInputCursor = true,
    this.maxInputLength,
    this.inputCursorWidth = 2.0,
    this.inputCursorColor,
    this.onSend,
    this.reverse = false,
    required this.userId,
    this.alwaysShowSend = false,
    this.inputFooterBuilder,
    this.sendButtonBuilder,
    this.showTrailingBeforeSend = true,
    this.inputToolbarPadding = const EdgeInsets.all(0.0),
    this.inputToolbarMargin = const EdgeInsets.all(0.0),
  }) : super(key: key);

  final Function() onTap;
  final TextEditingController? controller;
  final TextStyle? inputTextStyle;
  final InputDecoration? inputDecoration;
  final TextCapitalization? textCapitalization;
  final BoxDecoration? inputContainerStyle;
  final List<Widget> leading;
  final List<Widget> trailing;
  final int inputMaxLines;
  final int? maxInputLength;
  final bool alwaysShowSend;
  final String userId;
  final Function(ChatMessage)? onSend;
  final String? text;
  final Function(String)? onTextChange;
  final bool inputDisabled;
  final Widget Function(Function)? sendButtonBuilder;
  final Widget Function()? inputFooterBuilder;
  final bool showInputCursor;
  final double inputCursorWidth;
  final Color? inputCursorColor;
  final ScrollController? scrollController;
  final bool showTrailingBeforeSend;
  final FocusNode? focusNode;
  final EdgeInsets inputToolbarPadding;
  final EdgeInsets inputToolbarMargin;
  final TextDirection textDirection;
  final bool sendOnEnter;
  final bool reverse;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final ChatMessage message = ChatMessage(
      text: text!,
      senderId: userId,
      sentAt: DateTime.now(),
    );

    return Container(
      padding: inputToolbarPadding,
      margin: inputToolbarMargin,
      decoration:
          inputContainerStyle ?? const BoxDecoration(color: Colors.white),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ...leading,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Directionality(
                    textDirection: textDirection,
                    child: TextField(
                      focusNode: focusNode,
                      onChanged: (String value) {
                        onTextChange!(value);
                      },
                      onTap: onTap,
                      onSubmitted: (String value) {
                        if (sendOnEnter) {
                          _sendMessage(context, message);
                        }
                      },
                      textInputAction: textInputAction,
                      buildCounter: (
                        BuildContext context, {
                        int? currentLength,
                        int? maxLength,
                        bool? isFocused,
                      }) =>
                          null,
                      decoration: inputDecoration ??
                          const InputDecoration.collapsed(
                            hintText: '',
                            fillColor: Colors.white,
                          ),
                      textCapitalization: textCapitalization!,
                      controller: controller,
                      style: inputTextStyle,
                      maxLength: maxInputLength,
                      minLines: 1,
                      maxLines: inputMaxLines,
                      showCursor: showInputCursor,
                      cursorColor: inputCursorColor,
                      cursorWidth: inputCursorWidth,
                      enabled: !inputDisabled,
                    ),
                  ),
                ),
              ),
              if (showTrailingBeforeSend) ...trailing,
              if (sendButtonBuilder != null)
                sendButtonBuilder!(() async {
                  if (text!.isNotEmpty) {
                    await onSend!(message);

                    controller!.text = '';

                    onTextChange!('');
                  }
                })
              else
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: alwaysShowSend || text!.isNotEmpty
                      ? () => _sendMessage(context, message)
                      : null,
                ),
              if (!showTrailingBeforeSend) ...trailing,
            ],
          ),
          if (inputFooterBuilder != null) inputFooterBuilder!()
        ],
      ),
    );
  }

  Future<void> _sendMessage(BuildContext context, ChatMessage message) async {
    if (text!.isNotEmpty) {
      await onSend!(message);

      controller!.text = '';

      onTextChange!('');

      FocusScope.of(context).requestFocus(focusNode);

      Timer(
        const Duration(milliseconds: 150),
        () {
          scrollController!.animateTo(
            reverse ? 0.0 : scrollController!.position.maxScrollExtent + 30.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        },
      );
    }
  }
}
