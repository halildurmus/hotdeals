import '../chat/message_arguments.dart';

class CurrentRoute {
  String _routeName = '/';
  MessageArguments? _messageArguments;

  String get routeName => _routeName;

  MessageArguments? get messageArguments => _messageArguments;

  void updateRouteName(String routeName) {
    _routeName = routeName;
  }

  void clearRouteName() {
    _routeName = '';
  }

  void updateMessageArguments(MessageArguments messageArguments) {
    _messageArguments = messageArguments;
  }

  void clearMessageArguments() {
    _messageArguments = null;
  }

  @override
  String toString() {
    return 'CurrentRoute{routeName: $routeName, messageArguments: $messageArguments}';
  }
}
