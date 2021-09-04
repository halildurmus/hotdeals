import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;

typedef Json = Map<String, dynamic>;

/// An abstract class that used for communicating with the [FirebaseFirestore].
abstract class FirestoreService {
  Future<void> createMessageDocument({
    required String user1Uid,
    required String user2Uid,
  });

  Future<void> sendMessage({
    required String docID,
    required Json message,
  });

  Future<void> markMessagesAsSeen({
    required String docID,
    required String user2Uid,
  });

  Stream<QuerySnapshot<Json>> messagesStream(String userUid);
}
