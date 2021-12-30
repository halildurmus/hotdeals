import '../models/user_report_reason.dart';

typedef Json = Map<String, dynamic>;

class UserReport {
  const UserReport({
    this.id,
    this.reportedBy,
    required this.reportedUser,
    required this.reasons,
    this.message,
  });

  final String? id;
  final String? reportedBy;
  final String reportedUser;
  final List<UserReportReason> reasons;
  final String? message;

  Json toJson() => <String, dynamic>{
        'reportedUser': reportedUser,
        'reasons': reasons.map((e) => e.name.toUpperCase()).toList(),
        if (message != null) 'message': message,
      };

  @override
  String toString() =>
      'UserReport{id: $id, reportedBy: $reportedBy, reportedUser: $reportedUser, reasons: $reasons, message: $message}';
}
