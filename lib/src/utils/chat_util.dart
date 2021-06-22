/// A static class that contains useful utility functions for chat functionality.
class ChatUtil {
  /// Returns a [List] of [String], with the given parameters named [userId]
  /// and [peerId].
  static List<String> getUsersArray({
    required String userID,
    required String peerID,
  }) =>
      List<String>.of(userID.hashCode <= peerID.hashCode
          ? <String>[userID, peerID]
          : <String>[peerID, userID]);

  /// Returns a conversation ID, calculated with the given parameters named
  /// [userId] and [peerId].
  static String getConversationID({
    required String userID,
    required String peerID,
  }) =>
      userID.hashCode <= peerID.hashCode
          ? userID + '_' + peerID
          : peerID + '_' + userID;
}
