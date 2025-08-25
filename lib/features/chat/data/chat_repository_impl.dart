import 'package:chat_drop/core/services/database_helper.dart';
import 'package:chat_drop/features/chat/data/chat_remote_data_source.dart';
import 'package:chat_drop/features/chat/data/message_model.dart';
import 'package:chat_drop/features/chat/domain/chat_repository.dart';
import 'package:chat_drop/features/chat/domain/chat_session.dart';
import 'package:chat_drop/features/chat/domain/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final DatabaseHelper _databaseHelper;

  ChatRepositoryImpl(this._remoteDataSource, this._databaseHelper);

  @override
  Future<String> createSession(String currentUserId, String userName) async {
    return await _remoteDataSource.createSession(currentUserId, userName);
  }

  @override
  Future<void> joinSession(
    String sessionId,
    String userId,
    String userName,
  ) async {
    await _remoteDataSource.joinSession(sessionId, userId, userName);
  }

  @override
  Future<void> sendMessage(String sessionId, String content) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      senderId: currentUser.uid,
      content: content,
      timestamp: DateTime.now(),
      isSent: false,
      isRead: false,
    );

    // Save locally first
    await _databaseHelper.insertMessage(message, sessionId);

    // Send to remote
    try {
      await _remoteDataSource.sendMessage(message);
      await _databaseHelper.updateMessageStatus(message.id, isSent: true);
    } catch (e) {
      // Handle error - message remains as not sent
      print('Failed to send message: $e');
    }
  }

  @override
  Future<void> sendFriendRequest(String sessionId) async {
    await _remoteDataSource.sendFriendRequest(sessionId);
  }

  @override
  Future<void> acceptFriendRequest(String sessionId) async {
    await _remoteDataSource.acceptFriendRequest(sessionId);
  }

  @override
  Future<void> rejectFriendRequest(String sessionId) async {
    await _remoteDataSource.rejectFriendRequest(sessionId);
  }

  @override
  Stream<ChatSession?> getSession(String sessionId) {
    return _remoteDataSource.getSession(sessionId);
  }

  @override
  Stream<List<Message>> getMessages(String sessionId) {
    // Combine local and remote streams
    return _databaseHelper
        .getMessages(sessionId)
        .map((messages) => messages.cast<Message>());
  }

  @override
  Future<String> getFriendName(String sessionId, String currentUserId) async {
    final session = await _remoteDataSource.getSessionOnce(sessionId);
    if (session == null) return 'Unknown';

    // Find the other user
    final otherUserId = session.users.firstWhere(
      (userId) => userId != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return 'Unknown';

    // Get name from session userNames mapping
    return session.userNames?[otherUserId] ?? 'Friend';
  }
}
