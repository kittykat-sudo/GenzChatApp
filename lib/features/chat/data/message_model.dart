import 'package:chat_drop/features/chat/domain/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.sessionId,
    required super.senderId,
    required super.content,
    required super.timestamp,
    super.isSent,
    super.isRead,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isSent: data['isSent'] ?? false,
      isRead: data['isRead'] ?? false,
    );
  }

  factory MessageModel.fromDb(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'],
      sessionId: data['sessionId'],
      senderId: data['senderId'],
      content: data['content'],
      timestamp: DateTime.parse(data['timestamp']),
      isSent: data['isSent'] == 1,
      isRead: data['isRead'] == 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSent': isSent,
      'isRead': isRead,
    };
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'sessionId': sessionId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isSent': isSent ? 1 : 0,
      'isRead': isRead ? 1 : 0,
    };
  }
}
