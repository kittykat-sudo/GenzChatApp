import 'package:chat_drop/features/friends/data/friends_remote_datasource.dart';
import 'package:chat_drop/features/friends/domain/friends_repository.dart';
import 'package:chat_drop/features/friends/domain/models/friend.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDatasource _remoteDatasource;

  FriendsRepositoryImpl({required FriendsRemoteDatasource remoteDatasource})
    : _remoteDatasource = remoteDatasource;

  @override
  Stream<List<Friend>> getFriendsStream() {
    return _remoteDatasource.getFriendsStream();
  }

  @override
  Future<void> addFriend(Friend friend) {
    return _remoteDatasource.addFriend(friend);
  }

  @override
  Future<void> updateFriend(String friendId, Friend friend) {
    return _remoteDatasource.updateFriend(friendId, friend);
  }

  @override
  Future<void> removeFriend(String friendId) {
    return _remoteDatasource.removeFriend(friendId);
  }

  @override
  Future<void> updateLastMessage(
    String friendId,
    String message,
    DateTime timestamp,
  ) {
    return _remoteDatasource.updateLastMessage(friendId, message, timestamp);
  }

  @override
  Future<void> markAsRead(String friendId) {
    return _remoteDatasource.markAsRead(friendId);
  }

  @override
  Future<void> updateOnlineStatus(String friendId, bool isOnline) {
    return _remoteDatasource.updateOnlineStatus(friendId, isOnline);
  }
}
