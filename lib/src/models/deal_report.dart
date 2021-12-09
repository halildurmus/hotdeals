import '../models/deal_report_reason.dart';

typedef Json = Map<String, dynamic>;

class DealReport {
  const DealReport({
    this.id,
    this.reportedBy,
    required this.reportedDeal,
    required this.reasons,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory DealReport.fromJson(Json json) => DealReport(
        id: json['id'] as String,
        reportedBy: json['reportedBy'] as String,
        reportedDeal: json['reportedDeal'] as String,
        reasons: (json['reasons'] as List<dynamic>)
            .map((e) =>
                DealReportReason.values.byName((e as String).toLowerCase()))
            .toList(),
        message: json['message'] != null ? json['message'] as String : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String? reportedBy;
  final String reportedDeal;
  final List<DealReportReason> reasons;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      'reportedDeal': reportedDeal,
      'reasons': reasons.map((e) => e.name.toUpperCase()).toList(),
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return 'DealReport{id: $id, reportedBy: $reportedBy, reportedDeal: $reportedDeal, reasons: $reasons, message: $message, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
