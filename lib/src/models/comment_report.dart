import '../models/comment_report_reason.dart';
import '../utils/enum_util.dart';

typedef Json = Map<String, dynamic>;

class CommentReport {
  const CommentReport({
    required this.reportedComment,
    required this.reasons,
    this.message,
  });

  final String reportedComment;
  final Set<CommentReportReason> reasons;
  final String? message;

  Json toJson() => <String, dynamic>{
        'reasons': reasons.map((e) => e.javaName).toList(),
        if (message != null) 'message': message,
      };

  @override
  String toString() =>
      'CommentReport{reportedComment: $reportedComment, reasons: $reasons, message: $message}';
}
