import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../domain/chat_util.dart';

final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<QuerySnapshot<Map<String, dynamic>>, String>(
  (ref, userUid) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return firestoreService.messagesStreamByUserUid(userUid: userUid);
  },
  name: 'ChatMessagesStreamProvider',
);

final getMessageDocumentFutureProvider =
    FutureProvider.family<QuerySnapshot<Map<String, dynamic>>, List<String>>(
  (ref, usersArray) async => await ref
      .watch(firestoreServiceProvider)
      .getMessageDocument(usersArray: usersArray),
  name: 'GetMessageDocumentFutureProvider',
);

final firestoreServiceProvider = Provider<FirestoreService>(
    (ref) => FirestoreService(FirebaseFirestore.instance),
    name: 'FirestoreServiceProvider');

typedef Json = Map<String, dynamic>;

class FirestoreService with NetworkLoggy {
  const FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> createMessageDocument({
    required String user1Uid,
    required String user2Uid,
  }) async {
    final messagesRef = _firestore.collection('messages');
    final docId =
        ChatUtil.getConversationID(user1Uid: user1Uid, user2Uid: user2Uid);
    final usersArray =
        ChatUtil.getUsersArray(user1Uid: user1Uid, user2Uid: user2Uid);

    return messagesRef
        .doc(docId)
        .set(<String, dynamic>{
          'users': usersArray,
          'latestMessage': <String, dynamic>{},
        })
        .then((value) => loggy.info('Document created'))
        .catchError(
          (error) => loggy.error('Failed to create document: $error'),
        );
  }

  Future<void> sendMessage({
    required String docID,
    required Json message,
  }) async {
    final documentReference = _firestore
        .collection('messages')
        .doc(docID)
        .collection(docID)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    await _firestore.runTransaction(
      (transaction) async {
        transaction.set(documentReference, message);
      },
    );

    final latestMessage = _firestore.collection('messages').doc(docID);
    await _firestore.runTransaction(
      (transaction) async {
        transaction.set(
          latestMessage,
          <String, dynamic>{'latestMessage': message},
          SetOptions(merge: true),
        );
      },
    );
  }

  Future<void> markMessagesAsSeen({
    required String docID,
    required String user2Uid,
  }) async {
    final latestMessage =
        await _firestore.collection('messages').doc(docID).get();
    final isLatestMessageEmpty =
        (latestMessage.get('latestMessage') as Json).isEmpty;
    if (isLatestMessageEmpty) return;

    final latestMessageAuthorId =
        latestMessage.get('latestMessage')['author']['id'] as String;
    if (latestMessageAuthorId == user2Uid) {
      await _firestore.collection('messages').doc(docID).set({
        'latestMessage': {'status': 'seen'}
      }, SetOptions(merge: true));
    }

    final doc = await _firestore
        .collection('messages')
        .doc(docID)
        .collection(docID)
        .get();

    final docs = doc.docs.where((element) {
      final messageAuthorId = element.data()['author']['id'] as String;

      return messageAuthorId == user2Uid;
    });

    if (docs.isNotEmpty) {
      for (final doc in docs) {
        await doc.reference.update({'status': 'seen'});
      }
    }
  }

  Future<QuerySnapshot<Json>> getMessageDocument({
    required List<String> usersArray,
  }) =>
      _firestore
          .collection('messages')
          .where('users', isEqualTo: usersArray)
          .get();

  Stream<QuerySnapshot<Json>> messagesStreamByDocID({required String docID}) =>
      _firestore
          .collection('messages')
          .doc(docID)
          .collection(docID)
          .snapshots();

  Stream<QuerySnapshot<Json>> messagesStreamByUserUid(
          {required String userUid}) =>
      _firestore
          .collection('messages')
          .where('users', arrayContains: userUid)
          .orderBy('latestMessage.createdAt', descending: true)
          .snapshots();

  Future<void> updateMessagePreview({
    required String docID,
    required String messageID,
    required Json previewData,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection('messages')
        .doc(docID)
        .collection(docID)
        .where('id', isEqualTo: messageID)
        .get();

    if (doc.docs.isNotEmpty) {
      await doc.docs.first.reference.update({'previewData': previewData});
    }
  }
}
