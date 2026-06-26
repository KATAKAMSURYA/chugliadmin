class UserModel {
  final String id;
  final String email;
  final String displayName;
  final bool isSuspended;
  final bool isBanned;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.isSuspended = false,
    this.isBanned = false,
    required this.createdAt,
  });

  // Factory constructor for parsing Firebase data later
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Unknown User',
      isSuspended: data['isSuspended'] ?? false,
      isBanned: data['isBanned'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}
