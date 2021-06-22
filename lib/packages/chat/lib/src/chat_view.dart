part of dash_chat;

/// A complete chat UI which is inspired by [react-native-gifted-chat]
/// Highly customizable and helps developing chat UI faster
class DashChat extends StatefulWidget {
  final Function() onTap;

  /// Flex value for the message container defaults to 1
  /// Made so that the message container takes as much as possible
  /// if no height or width is passed explicitly
  final int messageContainerFlex;

  /// Set the chat into read only mode, meaning no way to send messages
  /// default to false
  final bool readOnly;

  /// Height for the Dash chat Widget
  final double? height;

  // Width for the Dash chat Widget
  final double? width;

  /// List of messages to display in the chat container
  /// Takes a [List] of [ChatMessage]
  final List<ChatMessage> messages;

  /// If provided, this text editing controller will be used for
  /// the text input.
  final TextEditingController? textController;

  /// If provided, this focus node will be used for the text input.
  final FocusNode? focusNode;

  /// Use to change the direction of the text ltr is used for
  /// launguages that start from left like English &
  /// rtl is used for languages like Arabic
  ///
  /// Defaults to `TextDirection.ltr`
  final TextDirection inputTextDirection;

  /// If provided will stop using the default controller
  /// i.e [TextEditingController] and will use this to update the
  /// text input field.
  final String? text;

  /// If the text parameter is passed then onTextChange must also
  /// be passed.
  final Function(String)? onTextChange;

  /// If the input TextField is disabled.
  final bool inputDisabled;

  /// Used to provide input decoration to the text as default only
  /// to the input placeholder for the chat input
  /// "Add Message here...".
  final InputDecoration? inputDecoration;

  ///Configures how the platform keyboard will select an uppercase or lowercase keyboard.
  ///Only supports text keyboards, other keyboard types will ignore this configuration. Capitalization is locale-aware.
  ///Defaults to [TextCapitalization.none]. Must not be null.
  final TextCapitalization textCapitalization;

  /// The current userId.
  final String userId;

  /// To function where you can make api calls and play
  /// with the [ChatMessage] obeject before make calls.
  final Function(ChatMessage) onSend;

  /// Should the send button be always active it defaults to false
  /// Usually it will only become active if some text is entered.
  final bool alwaysShowSend;

  /// Should the message be sent by hitting enter on web or text input action
  /// Can be useful for tablet or web usage
  final bool sendOnEnter;

  /// Input action of the keyboard
  final TextInputAction? textInputAction;

  /// [DateFormat] object for formatting date to show in [MessageListView]
  /// defaults to `yyyy-MM-dd`.
  final DateFormat? dateFormat;

  /// [DateFormat] object for formatting time to show in [MessageContainer]
  /// defaults to `HH:mm:ss`.
  final DateFormat? timeFormat;

  /// Should the user avatar be shown defaults to false and will not
  /// show the user avatar.
  final bool showUserAvatar;

  /// avatarBuilder will override the the default avatar which uses
  /// [CircleAvatar].
  final Widget Function(String)? avatarBuilder;

  /// Should the avatar be shown for every message defaults to false.
  final bool showAvatarForEveryMessage;

  /// [onPressAvatar] function takes a function with this structure
  /// [Function(ChatUser)] will trigger when the avatar
  /// is tapped on
  final Function(String)? onPressAvatar;

  /// [onLongPressAvatar] function takes a function with this structure
  /// [Function(ChatUser)] will trigger when the avatar
  /// is long pressed
  final Function(String)? onLongPressAvatar;

  /// [onLongPressMessage] function takes a function with this structure
  /// [Function(ChatMessage)] will trigger when the message
  /// is long pressed.
  final Function(ChatMessage)? onLongPressMessage;

  /// Should the messages be shown in reversed order.
  final bool inverted;

  /// messageBuilder will override the the default chat container which uses
  /// and you will need to build complete message Widget it will not accept
  /// and include any other builder functions.
  final Widget Function(ChatMessage)? messageBuilder;

  /// messageTextBuilder will override the the default message text.
  final Widget Function(String?, [ChatMessage])? messageTextBuilder;

  /// messageImageBuilder will override the the default Image.
  final Widget Function(String? url, [ChatMessage])? messageImageBuilder;

  /// messageTimeBuilder will override the the default text.
  final Widget Function(String formattedTime, [ChatMessage])?
      messageTimeBuilder;

  /// dateBuilder will override the the default time text.
  final Widget Function(String)? dateBuilder;

  /// A Widget that will be shown below the [MessageListView] like you can
  /// show a "tying..." at the end.
  final Widget Function()? chatFooterBuilder;

  /// Main input length of the input text box defaults to no limit.
  final int? maxInputLength;

  /// Used to parse text to make it linkified text uses
  /// [flutter_parsed_text](https://pub.dev/packages/flutter_parsed_text)
  /// takes a list of [MatchText] in order to parse Email, phone, links
  /// and can also add custom patterns using regex
  final List<MatchText> parsePatterns;

  /// Provides a custom style to the message container
  /// takes [BoxDecoration]
  final BoxDecoration? messageContainerDecoration;

  /// [List] of [Widget] to show before the [TextField].
  final List<Widget> leading;

  /// [List] of [Widget] to show after the [TextField].will remove the
  /// send button and will have to implement that yourself.
  final List<Widget> trailing;

  /// sendButtonBuilder will override the the default [IconButton].
  final Widget Function(Function)? sendButtonBuilder;

  /// Style for the [TextField].
  final TextStyle? inputTextStyle;

  /// [TextField] container style.
  final BoxDecoration? inputContainerStyle;

  /// Max length of the input lines default to 1.
  final int inputMaxLines;

  /// Should the input cursor be shown defaults to true.
  final bool showInputCursor;

  /// Width of the text input defaults to 2.0.
  final double inputCursorWidth;

  /// Color of the input cursor defaults to theme.
  final Color? inputCursorColor;

  /// ScrollController for the [MessageListView] will use the default
  /// scrollController in the Widget.
  final ScrollController? scrollController;

  /// A Widget that will be shown below the [ChatInputToolbar] like you can
  /// show a list of buttons like file image just like in Slack app.
  final Widget Function()? inputFooterBuilder;

  /// Padding for the [MessageListView].
  final EdgeInsetsGeometry messageContainerPadding;

  /// Callback method when the quickReply was tapped on
  /// will pass [Reply] as a parameter to function.
  final Function(Reply)? onQuickReply;

  /// Padding for the quick reply area
  /// by default it padding is set 0.0
  final EdgeInsetsGeometry quickReplyPadding;

  /// Container style for the QuickReply Container [BoxDecoration].
  final BoxDecoration? quickReplyStyle;

  /// [TextStyle] for QuickReply text style.
  final TextStyle? quickReplyTextStyle;

  /// quickReplyBuilder will override the the default QuickReply Widget.
  final Widget Function(Reply)? quickReplyBuilder;

  /// Should quick reply be horizontally scrollable
  final bool quickReplyScroll;

  /// Should the [trailing] Widgets be shown before the send button
  /// As default it will be shown before the send button.
  final bool showTrailingBeforeSend;

  /// Should the scroll to bottom widget be shown
  /// default to true.
  final bool scrollToBottom;

  final bool shouldStartMessagesFromTop;

  /// Overrides the default [scrollToBottomWidget] with a custom widget
  final Widget Function()? scrollToBottomWidget;

  /// Override the default behaviour of the onScrollToBottom Widget
  final Function? onScrollToBottomPress;

  /// Should the LoadEarlier Floating widget be shown or use
  /// load as you scroll scheme which will call the [onLoadEarlier]
  /// function as default it is set to this scheme which is false.
  /// false - load as you scroll scheme
  /// true - shows a loadEarlier Widget
  final bool shouldShowLoadEarlier;

  /// Override the default behaviour of the onScrollToBottom Widget
  final Widget Function()? showLoadEarlierWidget;

  /// Override the default behaviour of the onLoadEarlier Widget
  /// or used as a callback when the listView reaches the top
  final Function? onLoadEarlier;

  /// Padding for the default input toolbar
  /// by default it padding is set 0.0
  final EdgeInsets inputToolbarPadding;

  /// Margin for the default input toolbar
  /// by default it padding is set 0.0
  final EdgeInsets inputToolbarMargin;

  /// [messageButtonsBuilder] function takes a function with this
  /// structure [List<Widget> Function()] to render the buttons inside
  /// a row.
  final List<Widget> Function(ChatMessage)? messageButtonsBuilder;

  /// Padding of the message
  /// Default to EdgeInsets.all(8.0)
  final EdgeInsets messagePadding;

  /// Should show the text before the image in the [MessageContainer]
  /// or the opposite
  /// Default to `true`
  final bool textBeforeImage;

  /// sets the default [AvatarContainer] maxSize.
  ///
  /// Defaults to `30.0`
  final double avatarMaxSize;

  /// overrides the box decoration of the message
  /// can be used to override color, or customise the message container
  /// params [ChatMessage] and [isUser]: boolean
  /// return BoxDecoration
  final BoxDecoration Function(ChatMessage, bool?)? messageDecorationBuilder;

  late ScrollToBottomStyle scrollToBottomStyle;

  DashChat({
    Key? key,
    ScrollToBottomStyle? scrollToBottomStyle,
    required this.onTap,
    this.avatarMaxSize = 30.0,
    this.inputTextDirection = TextDirection.ltr,
    this.inputToolbarMargin = EdgeInsets.zero,
    this.inputToolbarPadding = EdgeInsets.zero,
    this.shouldShowLoadEarlier = false,
    this.showLoadEarlierWidget,
    this.onLoadEarlier,
    this.sendOnEnter = false,
    this.textInputAction,
    this.scrollToBottom = true,
    this.scrollToBottomWidget,
    this.onScrollToBottomPress,
    this.onQuickReply,
    this.quickReplyPadding = EdgeInsets.zero,
    this.quickReplyStyle,
    this.quickReplyTextStyle,
    this.quickReplyBuilder,
    this.quickReplyScroll = false,
    this.messageContainerPadding = const EdgeInsets.only(
      left: 2.0,
      right: 2.0,
    ),
    this.scrollController,
    this.inputCursorColor,
    this.inputCursorWidth = 2.0,
    this.showInputCursor = true,
    this.inputMaxLines = 1,
    this.inputContainerStyle,
    this.inputTextStyle,
    this.leading = const <Widget>[],
    this.trailing = const <Widget>[],
    this.messageContainerDecoration,
    this.messageContainerFlex = 1,
    this.height,
    this.width,
    this.readOnly = false,
    required this.messages,
    this.onTextChange,
    this.text,
    this.inputDisabled = false,
    this.textController,
    this.focusNode,
    this.inputDecoration,
    this.textCapitalization = TextCapitalization.none,
    this.alwaysShowSend = false,
    this.dateFormat,
    this.timeFormat,
    required this.userId,
    required this.onSend,
    this.onLongPressAvatar,
    this.onLongPressMessage,
    this.onPressAvatar,
    this.avatarBuilder,
    this.showAvatarForEveryMessage = false,
    this.showUserAvatar = false,
    this.inverted = false,
    this.maxInputLength,
    this.parsePatterns = const <MatchText>[],
    this.chatFooterBuilder,
    this.messageBuilder,
    this.inputFooterBuilder,
    this.sendButtonBuilder,
    this.dateBuilder,
    this.messageImageBuilder,
    this.messageTextBuilder,
    this.messageTimeBuilder,
    this.showTrailingBeforeSend = true,
    this.shouldStartMessagesFromTop = false,
    this.messageButtonsBuilder,
    this.messagePadding = const EdgeInsets.all(8.0),
    this.textBeforeImage = true,
    this.messageDecorationBuilder,
  }) : super(key: key) {
    this.scrollToBottomStyle = scrollToBottomStyle ?? ScrollToBottomStyle();
  }

  String? getVal() {
    return text;
  }

  @override
  DashChatState createState() => DashChatState();
}

class DashChatState extends State<DashChat> {
  FocusNode? inputFocusNode;
  TextEditingController? textController;
  late ScrollController scrollController;
  String _text = '';
  bool visible = false;
  GlobalKey inputKey = GlobalKey();
  double height = 48.0;
  bool showLoadMore = false;
  String get messageInput => _text;
  bool _initialLoad = true;
  Timer? _timer;

  void onTextChange(String text) {
    if (visible) {
      changeVisible(false);
    }
    setState(() {
      _text = text;
    });
  }

  void changeVisible(bool value) {
    if (widget.scrollToBottom) {
      setState(() {
        visible = value;
      });
    }
  }

  void changeDefaultLoadMore(bool value) {
    setState(() {
      showLoadMore = value;
    });
  }

  @override
  void initState() {
    scrollController = widget.scrollController ?? ScrollController();
    textController = widget.textController ?? TextEditingController();
    inputFocusNode = widget.focusNode ?? FocusNode();
    WidgetsBinding.instance!.addPostFrameCallback(widgetBuilt);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void widgetBuilt(Duration d) {
    final double initPos = widget.inverted
        ? 0.0
        : scrollController.position.maxScrollExtent + 25.0;

    scrollController
        .animateTo(
      initPos,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    )
        .whenComplete(() {
      _timer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _initialLoad = false;
          });
        }
      });
    });

    scrollController.addListener(() {
      final bool topReached = widget.inverted
          ? scrollController.offset >=
                  scrollController.position.maxScrollExtent &&
              !scrollController.position.outOfRange
          : scrollController.offset <=
                  scrollController.position.minScrollExtent &&
              !scrollController.position.outOfRange;

      if (widget.shouldShowLoadEarlier) {
        if (topReached) {
          setState(() {
            showLoadMore = true;
          });
        } else {
          setState(() {
            showLoadMore = false;
          });
        }
      } else if (topReached) {
        widget.onLoadEarlier!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth == double.infinity
            ? MediaQuery.of(context).size.width
            : constraints.maxWidth;
        final double maxHeight = constraints.maxWidth == double.infinity
            ? MediaQuery.of(context).size.height
            : constraints.maxHeight;
        return Stack(
          children: <Widget>[
            SizedBox(
              height: widget.height ?? maxHeight,
              width: widget.width ?? maxWidth,
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: widget.shouldStartMessagesFromTop
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: <Widget>[
                      MessageListView(
                          avatarMaxSize: widget.avatarMaxSize,
                          messagePadding: widget.messagePadding,
                          constraints: constraints,
                          shouldShowLoadEarlier: widget.shouldShowLoadEarlier,
                          showLoadEarlierWidget: widget.showLoadEarlierWidget,
                          onLoadEarlier: widget.onLoadEarlier,
                          defaultLoadCallback: changeDefaultLoadMore,
                          messageContainerPadding:
                              widget.messageContainerPadding as EdgeInsets,
                          scrollController:
                              widget.scrollController ?? scrollController,
                          userId: widget.userId,
                          messages: widget.messages,
                          showuserAvatar: widget.showUserAvatar,
                          dateFormat: widget.dateFormat,
                          timeFormat: widget.timeFormat,
                          inverted: widget.inverted,
                          showAvatarForEverMessage:
                              widget.showAvatarForEveryMessage,
                          onLongPressAvatar: widget.onLongPressAvatar,
                          onPressAvatar: widget.onPressAvatar,
                          onLongPressMessage: widget.onLongPressMessage,
                          avatarBuilder: widget.avatarBuilder,
                          messageBuilder: widget.messageBuilder,
                          messageTextBuilder: widget.messageTextBuilder,
                          messageImageBuilder: widget.messageImageBuilder,
                          messageTimeBuilder: widget.messageTimeBuilder,
                          dateBuilder: widget.dateBuilder,
                          messageContainerDecoration:
                              widget.messageContainerDecoration,
                          parsePatterns: widget.parsePatterns,
                          changeVisible: changeVisible,
                          visible: visible,
                          showLoadMore: showLoadMore,
                          messageButtonsBuilder: widget.messageButtonsBuilder,
                          messageDecorationBuilder:
                              widget.messageDecorationBuilder),
                      if (widget.chatFooterBuilder != null)
                        widget.chatFooterBuilder!(),
                      if (!widget.readOnly)
                        SafeArea(
                          child: ChatInputToolbar(
                              key: inputKey,
                              onTap: widget.onTap,
                              sendOnEnter: widget.sendOnEnter,
                              textInputAction: widget.textInputAction,
                              inputToolbarPadding: widget.inputToolbarPadding,
                              textDirection: widget.inputTextDirection,
                              inputToolbarMargin: widget.inputToolbarMargin,
                              showTrailingBeforeSend:
                                  widget.showTrailingBeforeSend,
                              inputMaxLines: widget.inputMaxLines,
                              controller: textController,
                              inputDecoration: widget.inputDecoration,
                              textCapitalization: widget.textCapitalization,
                              onSend: widget.onSend,
                              userId: widget.userId,
                              maxInputLength: widget.maxInputLength,
                              sendButtonBuilder: widget.sendButtonBuilder,
                              text: widget.text ?? _text,
                              onTextChange: widget.onTextChange ?? onTextChange,
                              inputDisabled: widget.inputDisabled,
                              leading: widget.leading,
                              trailing: widget.trailing,
                              inputContainerStyle: widget.inputContainerStyle,
                              inputTextStyle: widget.inputTextStyle,
                              inputFooterBuilder: widget.inputFooterBuilder,
                              inputCursorColor: widget.inputCursorColor,
                              inputCursorWidth: widget.inputCursorWidth,
                              showInputCursor: widget.showInputCursor,
                              alwaysShowSend: widget.alwaysShowSend,
                              scrollController:
                                  widget.scrollController ?? scrollController,
                              focusNode: inputFocusNode,
                              reverse: widget.inverted),
                        )
                    ],
                  ),
                  if (visible && !_initialLoad)
                    Positioned(
                      right: widget.scrollToBottomStyle.right,
                      left: widget.scrollToBottomStyle.left,
                      bottom: widget.scrollToBottomStyle.bottom,
                      top: widget.scrollToBottomStyle.top,
                      child: widget.scrollToBottomWidget != null
                          ? widget.scrollToBottomWidget!()
                          : ScrollToBottom(
                              onScrollToBottomPress:
                                  widget.onScrollToBottomPress,
                              scrollToBottomStyle: widget.scrollToBottomStyle,
                              scrollController:
                                  widget.scrollController ?? scrollController,
                              inverted: widget.inverted,
                            ),
                    ),
                ],
              ),
            ),
            if (widget.readOnly)
              Positioned(
                top: 0.0,
                child: Container(
                  height: 30.0,
                  width: maxWidth,
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 8.0,
                        child:
                            Icon(LineIcons.ban, color: Colors.red, size: 16.0),
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        "You've blocked this user",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
