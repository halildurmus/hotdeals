import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/chat_util.dart';

typedef Json = Map<String, dynamic>;

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> createMessageDocument({
    required String user1Uid,
    required String user2Uid,
  }) async {
    final CollectionReference<Json> messagesRef =
        firestore.collection('messages');
    final String docId =
        ChatUtil.getConversationID(user1Uid: user1Uid, user2Uid: user2Uid);
    final List<String> usersArray =
        ChatUtil.getUsersArray(user1Uid: user1Uid, user2Uid: user2Uid);

    messagesRef
        .doc(docId)
        .set(<String, dynamic>{
          'isTyping': <String, bool>{user1Uid: false, user2Uid: false},
          'users': usersArray,
          'latestMessage': <String, dynamic>{},
        })
        .then((value) => print('Document created'))
        .catchError(
          (dynamic error) => print('Failed to create document: $error'),
        );

    return docId;
  }

  // Future<void> createUserDocument({required String userId}) async {
  //   final CollectionReference<Json> usersRef = firestore.collection('users');
  //
  //   usersRef
  //       .doc(userId)
  //       .set(<String, dynamic>{
  //         'id': userId,
  //       }, SetOptions(merge: true))
  //       .then((value) => print('Document created'))
  //       .catchError(
  //         (dynamic error) => print('Failed to create document: $error'),
  //       );
  // }

  Future<String> sendMessage({
    required String docId,
    required String sender,
    required String message,
  }) async {
    final CollectionReference<Json> messagesRef =
        firestore.collection('messages').doc(docId).collection(docId);

    return messagesRef
        .add(<String, dynamic>{
          'isRead': false,
          'sentAt': DateTime.now(),
          'senderId': sender,
          'message': message
        })
        .then((DocumentReference<Json> value) => value.id)
        .catchError(
          (dynamic error) => print('Failed to create document: $error'),
        );
  }

  Future<bool> markAsRead({
    required String docId,
    required String messageDocId,
  }) async {
    final CollectionReference<Json> messagesRef =
        firestore.collection('messages').doc(docId).collection(docId);

    return messagesRef
        .doc(messageDocId)
        .update(<String, dynamic>{'isRead': true})
        .then((value) => true)
        .catchError(
          (dynamic error) => print('Failed to update document: $error'),
        );
  }

  // Future<bool> markAsTyping({
  //   required String docId,
  //   required String userId,
  // }) async {
  //   final CollectionReference<Json> messagesRef =
  //       firestore.collection('messages');
  //
  //   return messagesRef
  //       .doc(docId)
  //       .set(<String, dynamic>{
  //         'isTyping': <String, bool>{
  //           userId: true,
  //         },
  //       }, SetOptions(merge: true))
  //       .then((value) => true)
  //       .catchError(
  //         (dynamic error) => print('Failed to update document: $error'),
  //       );
  // }
}
