class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });
}
