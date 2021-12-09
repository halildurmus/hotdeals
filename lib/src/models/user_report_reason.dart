enum UserReportReason { harassing, spam, other }

/// Returns the proper [UserReportReason] for the given [str].
UserReportReason userReportReasonFromString(String str) =>
    UserReportReason.values
        .firstWhere((reason) => reason.name.toUpperCase() == str);
