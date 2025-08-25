import 'package:chat_drop/features/friends/domain/models/friend.dart';

abstract class FriendsRepository {
  // Stream of friends for the current user
  Stream<List<Friend>> getFriendsStream();

  // Add a new friend
  Future<void> addFriend(Friend friend);

  // Update friend information
  Future<void> updateFriend(String friendId, Friend friend);

  // Remove a friend
  Future<void> removeFriend(String friendId);

  // Update last message for a friend
  Future<void> updateLastMessage(
    String friendId,
    String message,
    DateTime timestamp,
  );

  // Mark messages as read
  Future<void> markAsRead(String friendId);

  // Update online status
  Future<void> updateOnlineStatus(String friendId, bool isOnline);
}
