typedef Json = Map<String, dynamic>;

class UserReport {
  const UserReport({
    this.id,
    this.reportedBy,
    required this.reportedUser,
    required this.reasons,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory UserReport.fromJson(Json json) => UserReport(
        id: json['id'] as String,
        reportedBy: json['reportedBy'] as String,
        reportedUser: json['reportedUser'] as String,
        reasons: List<String>.from(json['reasons'] as List<dynamic>),
        message: json['message'] != null ? json['message'] as String : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String? reportedBy;
  final String reportedUser;
  final List<String> reasons;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      if (reportedBy != null) 'reportedBy': reportedBy,
      'reportedUser': reportedUser,
      'reasons': reasons,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return 'UserReport{id: $id, reportedBy: $reportedBy, reportedUser: $reportedUser, reasons: $reasons, message: $message, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}