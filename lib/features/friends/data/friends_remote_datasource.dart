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

    if (kDebugMode) print('📡 Starting friends stream for user: $_currentUserId');
    
    return _friendsCollection
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          if (kDebugMode) print('📦 Received ${snapshot.docs.length} friends from Firestore');
          return snapshot.docs.map((doc) {
            try {
              return Friend.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            } catch (e) {
              if (kDebugMode) print('❌ Error parsing friend document ${doc.id}: $e');
              return null;
            }
          }).whereType<Friend>().toList();
        })
        .handleError((error) {
          if (kDebugMode) print('❌ Error in getFriendsStream: $error');
          return <Friend>[];
        });
  }

  Future<void> initializeSampleFriendsIfNeeded() async {
    if (kDebugMode) print('🔍 initializeSampleFriendsIfNeeded called');
    
    if (_currentUserId.isEmpty) {
      if (kDebugMode) print('⚠️ Cannot initialize friends: No authenticated user');
      throw Exception('No authenticated user found');
    }

    try {
      if (kDebugMode) print('🔍 Checking if friends collection exists for user: $_currentUserId');
      
      // Add timeout to prevent hanging
      final snapshot = await _friendsCollection
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      
      if (snapshot.docs.isNotEmpty) {
        if (kDebugMode) print('✅ Friends collection already exists with ${snapshot.docs.length} documents');
        return;
      }

      if (kDebugMode) print('🚀 Initializing sample friends for user: $_currentUserId');
      await _initializeSampleFriends();
      
    } catch (e) {
      if (kDebugMode) print('❌ Error checking/initializing friends: $e');
      rethrow; // Let the caller handle the error
    }
  }

  Future<void> _initializeSampleFriends() async {
    if (kDebugMode) print('📝 Creating sample friends data...');
    
    final now = DateTime.now();
    final sampleFriends = [
      Friend(
        id: 'marvin_mckinney',
        name: 'Marvin McKinney',
        avatar: '🧑🏿‍💼',
        isOnline: true,
        lastMessage: 'Hey, have you noticed how much...',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
      Friend(
        id: 'wade_warren',
        name: 'Wade Warren',
        avatar: '🧑🏼‍💼',
        isOnline: true,
        lastMessage: 'Absolutely! It\'s fascinating how p...',
        lastMessageTime: now.subtract(const Duration(minutes: 15)),
        isRead: true,
      ),
      Friend(
        id: 'eleanor_pena',
        name: 'Eleanor Pena',
        avatar: '👨🏻‍💼',
        isOnline: true,
        lastMessage: 'Hey, have you noticed how...',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        unreadCount: 2,
        isRead: false,
      ),
    ];

    try {
      if (kDebugMode) print('💾 Writing sample friends to Firestore...');
      
      final batch = _firestore.batch();
      for (final friend in sampleFriends) {
        batch.set(_friendsCollection.doc(friend.id), friend.toFirestore());
      }
      
      // Add timeout for batch write
      await batch.commit().timeout(const Duration(seconds: 15));
      if (kDebugMode) print('✅ Sample friends batch write completed successfully');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error during batch write: $e');
      rethrow;
    }
  }

  // Other methods with proper error handling...
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
    await _friendsCollection.doc(friendId).update(friend.toFirestore());
  }

  Future<void> removeFriend(String friendId) async {
    if (_currentUserId.isEmpty) return;
    await _friendsCollection.doc(friendId).delete();
  }

  Future<void> updateLastMessage(String friendId, String message, DateTime timestamp) async {
    if (_currentUserId.isEmpty) return;
    await _friendsCollection.doc(friendId).update({
      'lastMessage': message,
      'lastMessageTime': timestamp.millisecondsSinceEpoch,
      'isRead': false,
      'unreadCount': FieldValue.increment(1),
    });
  }

  Future<void> updateOnlineStatus(String friendId, bool isOnline) async {
    if (_currentUserId.isEmpty) return;
    await _friendsCollection.doc(friendId).update({'isOnline': isOnline});
  }
}