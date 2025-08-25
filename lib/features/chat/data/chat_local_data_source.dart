import 'package:chat_drop/core/services/database_helper.dart';
import 'package:chat_drop/features/chat/data/message_model.dart';

class ChatLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Stream of messages that updates whenever a new message is inserted.
  Stream<List<MessageModel>> getMessages(String sessionId) {
    return _dbHelper.getMessages(sessionId);
  }

  // Cache message in local DB (automatically triggers stream update)
  Future<void> cacheMessage(MessageModel message, String sessionId) async {
    await _dbHelper.insertMessage(message, sessionId);
  }

  // Update status flags (sent, read) — triggers stream refresh internally
  Future<void> updateMessageStatus(
    String messageId, {
    bool? isSent,
    bool? isRead,
  }) async {
    await _dbHelper.updateMessageStatus(
      messageId,
      isSent: isSent,
      isRead: isRead,
    );
  }
}
