/// A static class that contains useful utility functions for chat functionality.
class ChatUtil {
  /// Returns a conversation ID, calculated with the given parameters named
  /// [user1Uid] and [user2Uid].
  ///
  /// The order of the values calculated by their [hashCode].
  ///
  /// ```dart
  /// var conversationID = ChatUtil.getConversationID(user1Uid: '1235', user2Uid: '1234');
  /// print(conversationID); // '1235_1234'
  /// ```
  static String getConversationID({
    required String user1Uid,
    required String user2Uid,
  }) =>
      user1Uid.hashCode <= user2Uid.hashCode
          ? user1Uid + '_' + user2Uid
          : user2Uid + '_' + user2Uid;

  /// Extracts the user2's [uid] from the given [docID] using user1's [uid].
  ///
  /// ```dart
  /// var user2Uid = ChatUtil.getUser2Uid(docID: '1236_1234', user1Uid: '1234');
  /// print(user2Uid); // '1236'
  /// ```
  static String getUser2Uid({required String docID, required String user1Uid}) {
    final List<String> userUidList = docID.split('_');

    return user1Uid == userUidList[0] ? userUidList[1] : userUidList[0];
  }

  /// Constructs and returns a [List] of [String], calculated with the given
  /// parameters named [user1Uid] and [user2Uid].
  ///
  /// The order of the values calculated by their [hashCode].
  ///
  /// ```dart
  /// var arr = ChatUtil.getUsersArray(user1Uid: '1235', user2Uid: '1234');
  /// print(arr); // ['1235', '1234']
  /// ```
  static List<String> getUsersArray({
    required String user1Uid,
    required String user2Uid,
  }) =>
      List<String>.of(user1Uid.hashCode <= user2Uid.hashCode
          ? <String>[user1Uid, user2Uid]
          : <String>[user2Uid, user1Uid]);
}
