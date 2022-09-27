import '../../../helpers/enum_helper.dart';

enum UserReportReason { harassing, spam, other }

typedef Json = Map<String, dynamic>;

class UserReport {
  const UserReport({
    required this.reportedUser,
    required this.reasons,
    this.message,
  });

  final String reportedUser;
  final Set<UserReportReason> reasons;
  final String? message;

  Json toJson() => <String, dynamic>{
        'reasons': reasons.map((e) => e.javaName).toList(),
        if (message != null) 'message': message,
      };

  @override
  String toString() =>
      'UserReport{reportedUser: $reportedUser, reasons: $reasons, message: $message}';
}
