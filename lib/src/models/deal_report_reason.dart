enum DealReportReason { expired, repost, spam, other }

extension AsString on DealReportReason {
  String get asString => toString().toUpperCase().split('.').last;
}

/// Returns the proper [DealReportReason] for the given [str].
DealReportReason dealReportReasonFromString(String str) =>
    DealReportReason.values.firstWhere(
        (reason) => reason.toString().toUpperCase().split('.').last == str);
