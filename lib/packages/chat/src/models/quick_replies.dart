part of dash_chat;

/// Quick replies will contain all the replies that should
/// be shown to the user
class QuickReplies {
  /// [List] of replies that will be shown to the user
  List<Reply>? values;

  /// Should the quick replies be dismissible or persist
  bool? keepIt;

  QuickReplies({
    this.keepIt,
    this.values = const <Reply>[],
  });

  QuickReplies.fromJson(Map<dynamic, dynamic> json) {
    keepIt = json['keepIt'] as bool;

    if (json['values'] != null) {
      final List<Reply> replies = <Reply>[];

      for (int i = 0;
          i < (json['values'] as Map<String, dynamic>).length;
          i++) {
        replies.add(Reply.fromJson(json['values'][i] as Map<String, dynamic>));
      }

      values = replies;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['keepIt'] = keepIt;
    data['values'] = values!.map((Reply e) => e.toJson()).toList();

    return data;
  }
}
