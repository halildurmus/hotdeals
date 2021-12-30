import '../models/deal_report_reason.dart';

typedef Json = Map<String, dynamic>;

class DealReport {
  const DealReport({
    this.id,
    required this.reportedDeal,
    required this.reasons,
    this.message,
  });

  final String? id;
  final String reportedDeal;
  final List<DealReportReason> reasons;
  final String? message;

  Json toJson() => <String, dynamic>{
        'reportedDeal': reportedDeal,
        'reasons': reasons.map((e) => e.name.toUpperCase()).toList(),
        if (message != null) 'message': message,
      };

  @override
  String toString() =>
      'DealReport{id: $id, reportedDeal: $reportedDeal, reasons: $reasons, message: $message}';
}
