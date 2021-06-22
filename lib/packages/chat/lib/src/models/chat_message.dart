part of dash_chat;

/// A message data structure used by dash chat to handle messages
/// and also to handle quick replies
class ChatMessage {
  ChatMessage({
    this.isRead = false,
    required this.text,
    required this.senderId,
    DateTime? sentAt,
    this.image,
    this.video,
  }) {
    this.sentAt = sentAt ?? DateTime.now();
  }

  ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    senderId = json['senderId'] as String;
    sentAt = DateTime.fromMillisecondsSinceEpoch(json['sentAt'] as int);
    isRead = json['isRead'] as bool;
    text = json['message'] as String;
    image = json['image'] as String?;
    video = json['video'] as String?;
  }

  late bool isRead;

  /// Actual text message.
  late String text;

  /// It's a [non-optional] parameter which specifies the time the
  /// message was delivered takes a [DateTime] object.
  late DateTime sentAt;

  /// Sender userId.
  late String senderId;

  /// A [non-optional] parameter which is used to display images
  /// takes a [String] as a url
  String? image;

  /// A [non-optional] parameter which is used to display video
  /// takes a [String] as a url
  String? video;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    try {
      data['isRead'] = isRead;
      data['message'] = text;
      data['image'] = image;
      data['video'] = video;
      data['sentAt'] = sentAt.millisecondsSinceEpoch;
      data['senderId'] = senderId;
    } catch (e, stack) {
      print('ERROR caught when trying to convert ChatMessage to JSON:');
      print(e);
      print(stack);
    }

    return data;
  }
}
