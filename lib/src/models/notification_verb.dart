enum NotificationVerb { comment, message }

/// Returns the proper [NotificationVerb] for the given [str].
NotificationVerb notificationVerbFromString(String str) =>
    NotificationVerb.values.firstWhere((verb) => verb.name == str);
