import 'package:chat_drop/features/friends/data/friends_remote_datasource.dart';
import 'package:chat_drop/features/friends/domain/friends_repository.dart';
import 'package:chat_drop/features/friends/domain/models/friend.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource _remoteDataSource;

  FriendsRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> addTemporaryFriend({
    required String friendId,
    required String friendName,
    required String sessionId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    final friend = Friend(
      id: friendId,
      name: friendName,
      avatar: _generateAvatarEmoji(
        friendName,
      ), // Generate avatar emoji based on name
      status: FriendStatus.temporary,
      sessionId: sessionId,
      createdAt: DateTime.now(),
      isOnline: false,
      isRead: true,
      unreadCount: 0,
    );

    await _remoteDataSource.addFriend(currentUserId, friend);
  }

  @override
  Future<void> sendFriendRequest(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _remoteDataSource.updateFriendStatus(
      currentUserId,
      friendId,
      FriendStatus.pending,
      requestedBy: currentUserId,
    );
  }

  @override
  Future<void> acceptFriendRequest(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _remoteDataSource.updateFriendStatus(
      currentUserId,
      friendId,
      FriendStatus.permanent,
    );
  }

  @override
  Future<void> rejectFriendRequest(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _remoteDataSource.updateFriendStatus(
      currentUserId,
      friendId,
      FriendStatus.temporary,
      requestedBy: null,
    );
  }

  @override
  Stream<List<Friend>> getFriends() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _remoteDataSource.getFriendsStream(currentUserId);
  }

  @override
  Future<Friend?> getFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return null;

    return await _remoteDataSource.getFriend(currentUserId, friendId);
  }

  @override
  Future<void> updateLastMessage({
    required String friendId,
    required String message,
    required DateTime timestamp,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _remoteDataSource.updateLastMessage(
      currentUserId,
      friendId,
      message,
      timestamp,
    );
  }

  @override
  Future<void> removeFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _remoteDataSource.removeFriend(currentUserId, friendId);
  }

  // Add this method that was referenced in the providers
  Future<void> markAsRead(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _remoteDataSource.markAsRead(currentUserId, friendId);
  }

  // Helper method to generate avatar emoji based on name
  String _generateAvatarEmoji(String name) {
    final emojis = ['😊', '😎', '🥰', '😃', '🤗', '😄', '😁', '🙂', '😌', '😇'];
    final index = name.length % emojis.length;
    return emojis[index];
  }

  // Add this method to your FriendsRepositoryImpl:

  @override
  Future<void> updateFriendName(String friendId, String newName) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _remoteDataSource.updateFriendName(currentUserId, friendId, newName);
  }
}
