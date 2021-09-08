typedef Json = Map<String, dynamic>;

class Report {
  const Report({
    this.id,
    required this.reportedBy,
    this.reportedDeal,
    this.reportedUser,
    required this.reasons,
    this.message,
    this.createdAt,
    this.updatedAt,
  }) : assert(reportedDeal != null || reportedUser != null,
            'You need to specify the reportedDeal or the reportedUser!');

  factory Report.fromJson(Json json) => Report(
        id: json['id'] as String,
        reportedBy: json['reportedBy'] as String,
        reportedDeal: json['reportedDeal'] != null
            ? json['reportedDeal'] as String
            : null,
        reportedUser: json['reportedUser'] != null
            ? json['reportedUser'] as String
            : null,
        reasons: List<String>.from(json['reasons'] as List<dynamic>),
        message: json['message'] != null ? json['message'] as String : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String reportedBy;
  final String? reportedDeal;
  final String? reportedUser;
  final List<String> reasons;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      'reportedBy': reportedBy,
      if (reportedDeal != null) 'reportedDeal': reportedDeal,
      if (reportedUser != null) 'reportedUser': reportedUser,
      'reasons': reasons,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return 'Report{id: $id, reportedBy: $reportedBy, reportedDeal: $reportedDeal, reportedUser: $reportedUser, reasons: $reasons, message: $message, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
