import '../utils/enum_util.dart';

enum DealReportReason { expired, repost, spam, other }

typedef Json = Map<String, dynamic>;

class DealReport {
  const DealReport({
    required this.reportedDeal,
    required this.reasons,
    this.message,
  });

  final String reportedDeal;
  final Set<DealReportReason> reasons;
  final String? message;

  Json toJson() => <String, dynamic>{
        'reasons': reasons.map((e) => e.javaName).toList(),
        if (message != null) 'message': message,
      };

  @override
  String toString() =>
      'DealReport{reportedDeal: $reportedDeal, reasons: $reasons, message: $message}';
}
