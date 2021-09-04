enum NotificationVerb { comment, message }

extension AsString on NotificationVerb {
  String get asString => toString().split('.').last;
}

/// Returns the proper [NotificationVerb] for the given [str].
NotificationVerb notificationVerbFromString(String str) {
  return NotificationVerb.values.firstWhere(
      (NotificationVerb verb) => verb.toString().split('.').last == str);
}
