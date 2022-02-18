import '../chat/message_arguments.dart';

class CurrentRoute {
  String routeName = '/';
  MessageArguments? messageArguments;

  @override
  String toString() =>
      'CurrentRoute{routeName: $routeName, messageArguments: $messageArguments}';
}
