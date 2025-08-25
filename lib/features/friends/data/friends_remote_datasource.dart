import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:chat_drop/features/friends/domain/models/friend.dart';

class FriendsRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  CollectionReference get _friendsCollection =>
      _firestore.collection('users').doc(_currentUserId).collection('friends');

  Stream<List<Friend>> getFriendsStream() {
    if (_currentUserId.isEmpty) {
      if (kDebugMode) print('⚠️ No authenticated user, returning empty stream');
      return Stream.value([]);
    }

    if (kDebugMode)
      print('📡 Starting friends stream for user: $_currentUserId');

    return _friendsCollection
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          if (kDebugMode)
            print('📦 Received ${snapshot.docs.length} friends from Firestore');
          return snapshot.docs
              .map((doc) {
                try {
                  return Friend.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                } catch (e) {
                  if (kDebugMode)
                    print('❌ Error parsing friend document ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Friend>()
              .toList();
        })
        .handleError((error) {
          if (kDebugMode) print('❌ Error in getFriendsStream: $error');
          return <Friend>[];
        });
  }

  // Removed sample friends initialization - no longer needed
  // The app will naturally show "No friends" state when collection is empty

  Future<void> addFriend(Friend friend) async {
    if (_currentUserId.isEmpty) {
      throw Exception('No authenticated user');
    }
    try {
      await _friendsCollection.doc(friend.id).set(friend.toFirestore());
      if (kDebugMode) print('✅ Friend added: ${friend.name}');
    } catch (e) {
      if (kDebugMode) print('❌ Error adding friend: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String friendId) async {
    if (_currentUserId.isEmpty) return;
    try {
      await _friendsCollection.doc(friendId).update({
        'isRead': true,
        'unreadCount': 0,
      });
    } catch (e) {
      if (kDebugMode) print('❌ Error marking as read: $e');
    }
  }

  Future<void> updateFriend(String friendId, Friend friend) async {
    if (_currentUserId.isEmpty) return;
    try {
      await _friendsCollection.doc(friendId).update(friend.toFirestore());
      if (kDebugMode) print('✅ Friend updated: ${friend.name}');
    } catch (e) {
      if (kDebugMode) print('❌ Error updating friend: $e');
      rethrow;
    }
  }

  Future<void> removeFriend(String friendId) async {
    if (_currentUserId.isEmpty) return;
    try {
      await _friendsCollection.doc(friendId).delete();
      if (kDebugMode) print('✅ Friend removed: $friendId');
    } catch (e) {
      if (kDebugMode) print('❌ Error removing friend: $e');
      rethrow;
    }
  }

  Future<void> updateLastMessage(
    String friendId,
    String message,
    DateTime timestamp,
  ) async {
    if (_currentUserId.isEmpty) return;
    try {
      await _friendsCollection.doc(friendId).update({
        'lastMessage': message,
        'lastMessageTime': timestamp.millisecondsSinceEpoch,
        'isRead': false,
        'unreadCount': FieldValue.increment(1),
      });
      if (kDebugMode) print('✅ Last message updated for friend: $friendId');
    } catch (e) {
      if (kDebugMode) print('❌ Error updating last message: $e');
    }
  }

  Future<void> updateOnlineStatus(String friendId, bool isOnline) async {
    if (_currentUserId.isEmpty) return;
    try {
      await _friendsCollection.doc(friendId).update({'isOnline': isOnline});
      if (kDebugMode) print('✅ Online status updated for friend: $friendId to $isOnline');
    } catch (e) {
      if (kDebugMode) print('❌ Error updating online status: $e');
    }
  }
}