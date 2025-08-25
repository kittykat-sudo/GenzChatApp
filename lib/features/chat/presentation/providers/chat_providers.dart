import 'package:chat_drop/core/services/database_helper.dart';
import 'package:chat_drop/features/chat/data/chat_remote_data_source.dart';
import 'package:chat_drop/features/chat/data/chat_repository_impl.dart';
import 'package:chat_drop/features/chat/domain/chat_repository.dart';
import 'package:chat_drop/features/chat/domain/chat_session.dart';
import 'package:chat_drop/features/chat/domain/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ChatRemoteDataSource(), DatabaseHelper.instance);
});

// Session provider
final sessionProvider = StreamProvider.family<ChatSession?, String>((
  ref,
  sessionId,
) {
  final repository = ref.read(chatRepositoryProvider);
  return repository.getSession(sessionId);
});

// Messages provider
final messagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  sessionId,
) {
  final repository = ref.read(chatRepositoryProvider);
  return repository.getMessages(sessionId);
});

// Friend name provider
final friendNameProvider = FutureProvider.family<String, String>((
  ref,
  sessionId,
) async {
  final repository = ref.read(chatRepositoryProvider);
  final currentUserId = ref.read(currentUserIdProvider);
  return await repository.getFriendName(sessionId, currentUserId);
});

// Current user ID provider (add this to auth providers if not exists)
final currentUserIdProvider = Provider<String>((ref) {
  // Get from Firebase Auth or your auth state
  return 'current_user_id'; // Replace with actual implementation
});
