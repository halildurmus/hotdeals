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
        reasons: List<String>.from(json['reasons'] as List<dynamic>),
        message: json['message'] != null ? json['message'] as String : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String? reportedBy;
  final String reportedDeal;
  final List<String> reasons;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      if (reportedBy != null) 'reportedBy': reportedBy,
      'reportedDeal': reportedDeal,
      'reasons': reasons,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return 'DealReport{id: $id, reportedBy: $reportedBy, reportedDeal: $reportedDeal, reasons: $reasons, message: $message, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
