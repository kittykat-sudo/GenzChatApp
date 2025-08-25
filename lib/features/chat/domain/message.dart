class Message {
  final String id;
  final String sessionId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isSent;
  final bool isRead;

  Message({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isSent = false,
    this.isRead = false,
  });
}
