import '../../../helpers/enum_helper.dart';

enum CommentReportReason { harassing, spam, other }

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

  Json toJson() => {
        'reasons': reasons.map((e) => e.javaName).toList(),
        if (message != null) 'message': message,
      };

  @override
  String toString() =>
      'CommentReport{reportedComment: $reportedComment, reasons: $reasons, message: $message}';
}
