import '../models/my_user.dart';

class MessageArguments {
  MessageArguments({
    required this.docId,
    required this.user2,
  });

  final String docId;
  final MyUser user2;

  @override
  String toString() {
    return 'MessageArguments{docId: $docId, user2: $user2}';
  }
}
