import 'package:chat_drop/core/services/database_helper.dart';
import 'package:chat_drop/features/chat/data/chat_remote_data_source.dart';
import 'package:chat_drop/features/chat/data/chat_repository_impl.dart';
import 'package:chat_drop/features/chat/domain/chat_repository.dart';
import 'package:chat_drop/features/chat/domain/chat_session.dart';
import 'package:chat_drop/features/chat/domain/message.dart';
import 'package:chat_drop/features/friends/presentation/providers/friends_providers.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

// Friend name provider that watches friends changes
final currentChatFriendNameProvider = StreamProvider<String>((ref) async* {
  final friendId = ref.watch(currentChatFriendIdProvider);

  print("currentChatFriendNameProvider called with friendId: $friendId");

  if (friendId == null) {
    print("No friend ID available");
    yield 'Unknown';
    return;
  }

  print("Watching friend name for ID: $friendId");

  // Watch the friends stream and extract the specific friend's name
  final friendsAsync = ref.watch(friendsStreamProvider);

  yield* friendsAsync.when(
    data: (friends) async* {
      print("Friends data received, count: ${friends.length}");
      print("Looking for friend with ID: $friendId");

      try {
        final friend = friends.firstWhere((f) {
          print("Checking friend: ${f.id} == $friendId ? ${f.id == friendId}");
          return f.id == friendId;
        });

        final friendName = friend.name;
        print("Found friend name: $friendName");
        yield friendName;
      } catch (e) {
        print("Friend not found in friends list: $e");
        print("Available friend IDs: ${friends.map((f) => f.id).toList()}");
        yield 'Unknown';
      }
    },
    loading: () async* {
      print("Friends data loading...");
      yield 'Loading...';
    },
    error: (error, stack) async* {
      print('Error in friends stream: $error');
      yield 'Unknown';
    },
  );
});

// Alternative provider that gets friend name directly
final directFriendNameProvider = FutureProvider.family<String, String>((
  ref,
  friendId,
) async {
  try {
    print("Getting friend name directly for ID: $friendId");
    final friendsRepository = ref.read(friendsRepositoryProvider);
    final friend = await friendsRepository.getFriend(friendId);

    if (friend != null) {
      print("Found friend directly: ${friend.name}");
      return friend.name;
    } else {
      print("Friend not found directly");
      return 'Unknown';
    }
  } catch (e) {
    print('Error getting friend directly: $e');
    return 'Unknown';
  }
});

// Friend name provider for session-based lookup
final friendNameProvider = FutureProvider.family<String, String>((
  ref,
  sessionId,
) async {
  try {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return 'Unknown';

    // Get the session to find the other user
    final repository = ref.read(chatRepositoryProvider);
    final sessionStream = repository.getSession(sessionId);
    final session = await sessionStream.first;

    if (session == null) return 'Unknown';

    // Find the other user in the session
    final otherUserId = session.users.firstWhere(
      (userId) => userId != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return 'Unknown';

    // Get friend name from friends collection
    final friendsRepository = ref.read(friendsRepositoryProvider);
    final friend = await friendsRepository.getFriend(otherUserId);

    if (friend != null) {
      return friend.name;
    }

    // Fallback to session userNames
    if (session.userNames != null &&
        session.userNames!.containsKey(otherUserId)) {
      return session.userNames![otherUserId]!;
    }

    return 'Friend';
  } catch (e) {
    print('Error getting friend name: $e');
    return 'Unknown';
  }
});

// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  return currentUser?.uid;
});

// Current user stream provider (for real-time updates)
final currentUserStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Chat actions provider
final chatActionsProvider = Provider((ref) => ChatActions(ref));

class ChatActions {
  final Ref _ref;
  ChatActions(this._ref);

  Future<void> markMessageAsRead(String messageId) async {
    try {
      final repository = _ref.read(chatRepositoryProvider);
      await repository.markMessageAsRead(messageId);
    } catch (e) {
      print('Failed to mark message as read: $e');
    }
  }

  Future<void> markAllMessagesAsRead(String sessionId) async {
    try {
      final repository = _ref.read(chatRepositoryProvider);
      final currentUserId = _ref.read(currentUserIdProvider);
      if (currentUserId != null) {
        await repository.markAllMessagesAsRead(sessionId, currentUserId);
      }
    } catch (e) {
      print('Failed to mark all messages as read: $e');
    }
  }

  Future<void> sendMessage(String sessionId, String content) async {
    try {
      final repository = _ref.read(chatRepositoryProvider);
      await repository.sendMessage(sessionId, content);
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  Future<void> sendFriendRequest(String sessionId) async {
    try {
      final repository = _ref.read(chatRepositoryProvider);
      await repository.sendFriendRequest(sessionId);
    } catch (e) {
      print('Failed to send friend request: $e');
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String sessionId) async {
    try {
      final repository = _ref.read(chatRepositoryProvider);
      await repository.acceptFriendRequest(sessionId);
    } catch (e) {
      print('Failed to accept friend request: $e');
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(String sessionId) async {
    try {
      final repository = _ref.read(chatRepositoryProvider);
      await repository.rejectFriendRequest(sessionId);
    } catch (e) {
      print('Failed to reject friend request: $e');
      rethrow;
    }
  }
}
