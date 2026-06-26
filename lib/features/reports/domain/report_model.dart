class ReportModel {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reportedUserName;
  final String reason;
  final String status; // 'pending', 'resolved', 'rejected'
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    required this.status,
    required this.createdAt,
  });
}
