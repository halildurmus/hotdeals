import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../utils/chat_util.dart';
import 'firestore_service.dart';

typedef Json = Map<String, dynamic>;

class FirestoreServiceImpl with NetworkLoggy implements FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createMessageDocument({
    required String user1Uid,
    required String user2Uid,
  }) async {
    final CollectionReference<Json> messagesRef =
        _firestore.collection('messages');
    final String docId =
        ChatUtil.getConversationID(user1Uid: user1Uid, user2Uid: user2Uid);
    final List<String> usersArray =
        ChatUtil.getUsersArray(user1Uid: user1Uid, user2Uid: user2Uid);

    return messagesRef
        .doc(docId)
        .set(<String, dynamic>{
          'users': usersArray,
          'latestMessage': <String, dynamic>{},
        })
        .then((value) => loggy.info('Document created'))
        .catchError(
          (dynamic error) => loggy.error('Failed to create document: $error'),
        );
  }

  @override
  Future<void> sendMessage({
    required String docID,
    required Json message,
  }) async {
    final DocumentReference<Json> documentReference = _firestore
        .collection('messages')
        .doc(docID)
        .collection(docID)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    await _firestore.runTransaction(
      (Transaction transaction) async {
        transaction.set(documentReference, message);
      },
    );

    final DocumentReference<Json> _latestMessage =
        _firestore.collection('messages').doc(docID);

    await _firestore.runTransaction(
      (Transaction transaction) async {
        transaction.set(
          _latestMessage,
          <String, dynamic>{'latestMessage': message},
          SetOptions(merge: true),
        );
      },
    );
  }

  @override
  Future<void> markMessagesAsSeen({
    required String docID,
    required String user2Uid,
  }) async {
    final DocumentSnapshot<Json> latestMessage =
        await _firestore.collection('messages').doc(docID).get();
    final bool isLatestMessageEmpty =
        (latestMessage.get('latestMessage') as Json).isEmpty;
    if (isLatestMessageEmpty) {
      return;
    }

    final String latestMessageAuthorId =
        latestMessage.get('latestMessage')['author']['id'] as String;

    if (latestMessageAuthorId == user2Uid) {
      _firestore
          .collection('messages')
          .doc(docID)
          .set(<String, dynamic>{
            'latestMessage': <String, dynamic>{
              'status': 'seen',
            },
          }, SetOptions(merge: true))
          .then((value) {})
          .catchError(
            (dynamic error) {
              loggy.error('Failed to update document: $error');
            },
          );
    }

    final QuerySnapshot<Json> doc = await _firestore
        .collection('messages')
        .doc(docID)
        .collection(docID)
        .get();

    final Iterable<QueryDocumentSnapshot<Json>> docs =
        doc.docs.where((QueryDocumentSnapshot<Json> element) {
      final String messageAuthorId = element.data()['author']['id'] as String;

      return messageAuthorId == user2Uid;
    });

    if (docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Json> doc in docs) {
        doc.reference.update(<String, dynamic>{
          'status': 'seen',
        });
      }
    }
  }

  @override
  Future<QuerySnapshot<Json>> getMessageDocument({
    required List<String> usersArray,
  }) {
    return _firestore
        .collection('messages')
        .where('users', isEqualTo: usersArray)
        .get();
  }

  @override
  Stream<QuerySnapshot<Json>> messagesStreamByDocID({required String docID}) {
    return _firestore
        .collection('messages')
        .doc(docID)
        .collection(docID)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<Json>> messagesStreamByUserUid(
      {required String userUid}) {
    return _firestore
        .collection('messages')
        .where('users', arrayContains: userUid)
        .orderBy('latestMessage.createdAt', descending: true)
        .snapshots();
  }

  @override
  Future<void> updateMessagePreview({
    required String docID,
    required String messageID,
    required Json previewData,
  }) async {
    final QuerySnapshot<Json> _doc = await FirebaseFirestore.instance
        .collection('messages')
        .doc(docID)
        .collection(docID)
        .where('id', isEqualTo: messageID)
        .get();

    if (_doc.docs.isNotEmpty) {
      _doc.docs.first.reference.update(<String, dynamic>{
        'previewData': previewData,
      });
    }
  }
}
