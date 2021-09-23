enum UserReportReason { harassing, spam, other }

extension AsString on UserReportReason {
  String get asString => toString().toUpperCase().split('.').last;
}

/// Returns the proper [UserReportReason] for the given [str].
UserReportReason userReportReasonFromString(String str) {
  return UserReportReason.values.firstWhere(
      (reason) => reason.toString().toUpperCase().split('.').last == str);
}
