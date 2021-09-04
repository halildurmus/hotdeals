import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

typedef Json = Map<String, dynamic>;

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

  /// Constructs a [Json] from the given [message].
  static Json messageToJson({required types.Message message}) {
    final bool isFileMessage = message is types.FileMessage;
    final bool isImageMessage = message is types.ImageMessage;
    final bool isTextMessage = message is types.TextMessage;

    return <String, dynamic>{
      'id': message.id,
      'author': <String, dynamic>{'id': message.author.id},
      'createdAt': message.createdAt,
      if (isImageMessage) 'height': message.height,
      if (isFileMessage) 'mimeType': message.mimeType,
      if (isFileMessage)
        'name': message.name
      else if (isImageMessage)
        'name': message.name,
      if (isFileMessage)
        'size': message.size
      else if (isImageMessage)
        'size': message.size,
      'status': message.status.toString().split('.').last,
      if (isTextMessage) 'text': message.text,
      'type': isFileMessage
          ? 'file'
          : isImageMessage
              ? 'image'
              : 'text',
      if (isFileMessage)
        'uri': message.uri
      else if (isImageMessage)
        'uri': message.uri,
      if (isImageMessage) 'width': message.width,
    };
  }
}
