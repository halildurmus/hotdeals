enum DealReportReason { expired, repost, spam, other }

/// Returns the proper [DealReportReason] for the given [str].
DealReportReason dealReportReasonFromString(String str) =>
    DealReportReason.values
        .firstWhere((reason) => reason.name.toUpperCase() == str);
