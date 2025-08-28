import 'package:chat_drop/features/chat/domain/chat_session.dart';
import 'package:chat_drop/features/chat/domain/message.dart';

abstract class ChatRepository {
  Future<String> createSession(String currentUserId, String userName);
  Future<void> joinSession(String sessionId, String userId, String userName);
  Future<void> sendMessage(String sessionId, String content);
  Future<void> sendFriendRequest(String sessionId);
  Future<void> acceptFriendRequest(String sessionId);
  Future<void> rejectFriendRequest(String sessionId);

  Stream<ChatSession?> getSession(String sessionId);
  Stream<List<Message>> getMessages(String sessionId);

  // Get friend's name from session
  Future<String> getFriendName(String sessionId, String currentUserId);

  // Message status methods - simplified without MessageStatus enum
  Future<void> markAllMessagesAsRead(String sessionId, String currentUserId);
  Future<void> markMessageAsRead(String messageId);
  Future<void> markMessageAsDelivered(String messageId);
  Future<void> updateMessageReadStatus(String messageId, bool isRead);
  Future<void> updateMessageSentStatus(String messageId, bool isSent);

  Future<List<Message>> getLastMessage(String sessionId);
}
