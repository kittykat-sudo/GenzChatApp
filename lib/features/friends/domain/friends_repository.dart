import 'package:chat_drop/features/friends/domain/models/friend.dart';

abstract class FriendsRepository {
  // Add friend as temporary after QR scan
  Future<void> addTemporaryFriend({
    required String friendId,
    required String friendName,
    required String sessionId,
  });

  // Send friend request (temporary -> pending)
  Future<void> sendFriendRequest(String friendId);

  // Accept friend request (pending -> permanent)
  Future<void> acceptFriendRequest(String friendId);

  // Reject friend request (pending -> temporary)
  Future<void> rejectFriendRequest(String friendId);

  // Get all friends stream
  Stream<List<Friend>> getFriends();

  // Get specific friend
  Future<Friend?> getFriend(String friendId);

  // Update last message info
  Future<void> updateLastMessage({
    required String friendId,
    required String message,
    required DateTime timestamp,
  });

  // Remove friend completely
  Future<void> removeFriend(String friendId);

  // Mark friend's messages as read
  Future<void> markAsRead(String friendId);

  Future<void> updateFriendName(String friendId, String newName);
}
