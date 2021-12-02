import '../utils/enum_util.dart';
export '../utils/enum_util.dart';

enum UserReportReason { harassing, spam, other }

/// Returns the proper [UserReportReason] for the given [str].
UserReportReason userReportReasonFromString(String str) =>
    UserReportReason.values.firstWhere((reason) => reason.name == str);
