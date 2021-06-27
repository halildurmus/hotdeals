part of dash_chat;

/// Used for providing replies in quick replies
class Reply {
  Reply({
    required this.title,
    this.messageId,
    this.value,
  });

  Reply.fromJson(Map<dynamic, dynamic> json) {
    title = json['title'] as String;
    value = json['value'] as String;
    messageId = json['messageId'];
  }

  /// Message shown to the user
  late String title;

  /// Actual value underneath the message
  /// It's an [optional] parameter
  String? value;

  /// If no messageId is provided it will use [UUID v4] to
  /// set a default id for that message
  dynamic messageId;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['messageId'] = messageId;
    data['title'] = title;
    data['value'] = value;

    return data;
  }
}
