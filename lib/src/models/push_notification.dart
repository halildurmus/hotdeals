typedef Json = Map<String, dynamic>;

class PushNotification {
  PushNotification({
    this.id,
    required this.title,
    required this.body,
    required this.dataTitle,
    required this.dataBody,
    this.isRead = false,
    this.createdAt,
  }) {
    createdAt ??= DateTime.now();
  }

  /// Creates a [PushNotification] from a [Map].
  factory PushNotification.fromMap(Map<String, Object?> map) =>
      PushNotification(
        id: map['id']! as int,
        title: map['title']! as String,
        body: map['body']! as String,
        dataTitle: map['data_title']! as String,
        dataBody: map['data_body']! as String,
        isRead: map['is_read']! == 1,
        createdAt: DateTime.parse(map['created_at']! as String),
      );

  final int? id;
  final String title;
  final String body;
  final String dataTitle;
  final String dataBody;
  bool isRead;
  late final DateTime? createdAt;

  /// Converts a [PushNotification] into a [Map].
  /// The keys must correspond to the names of the columns in the database.
  Json toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'data_title': dataTitle,
        'data_body': dataBody,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt!.toIso8601String(),
      };

  @override
  String toString() {
    return 'PushNotification{id: $id, title: $title, body: $body, dataTitle: $dataTitle, dataBody: $dataBody, isRead: $isRead, createdAt: $createdAt}';
  }
}
