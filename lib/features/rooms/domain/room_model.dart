class RoomModel {
  final String id;
  final String name;
  final String category;
  final int participantCount;
  final bool isClosed;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.category,
    required this.participantCount,
    this.isClosed = false,
    required this.createdAt,
  });
}
