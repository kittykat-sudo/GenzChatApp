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
        .snapshots(includeMetadataChanges: false) // Avoid unnecessary updates
        .map((snapshot) {
          if (kDebugMode) print('📦 Received ${snapshot.docs.length} friends from Firestore');
          
          final friends = <Friend>[];
          for (final doc in snapshot.docs) {
            try {
              final friend = Friend.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              friends.add(friend);
            } catch (e) {
              if (kDebugMode) print('❌ Error parsing friend document ${doc.id}: $e');
            }
          }
          return friends;
        })
        .handleError((error) {
          if (kDebugMode) print('❌ Error in getFriendsStream: $error');
        });
  }

  Future<void> initializeSampleFriendsIfNeeded() async {
    if (_currentUserId.isEmpty) {
      if (kDebugMode) print('⚠️ Cannot initialize friends: No authenticated user');
      return;
    }

    try {
      if (kDebugMode) print('🔍 Checking if friends collection exists for user: $_currentUserId');
      
      // Use a more efficient query
      final snapshot = await _friendsCollection.limit(1).get(const GetOptions(source: Source.cache));
      
      if (snapshot.docs.isNotEmpty) {
        if (kDebugMode) print('✅ Friends collection already exists');
        return;
      }

      // Check server if cache is empty
      final serverSnapshot = await _friendsCollection.limit(1).get();
      if (serverSnapshot.docs.isNotEmpty) {
        if (kDebugMode) print('✅ Friends collection exists on server');
        return;
      }

      if (kDebugMode) print('🚀 Initializing sample friends for user: $_currentUserId');
      
      // Initialize in background without blocking
      _initializeSampleFriends();
      
    } catch (e) {
      if (kDebugMode) print('❌ Error checking friends collection: $e');
    }
  }

  Future<void> _initializeSampleFriends() async {
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
      Friend(
        id: 'jane_cooper',
        name: 'Jane Cooper',
        avatar: '👩🏽‍🎨',
        isOnline: false,
        lastMessage: 'I think it\'s great. The vibrant...',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 2,
        isRead: false,
      ),
      Friend(
        id: 'kristin_watson',
        name: 'Kristin Watson',
        avatar: '👩🏻‍💼',
        isOnline: true,
        lastMessage: 'It\'s like a never-ending groove.',
        lastMessageTime: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      Friend(
        id: 'dianne_russell',
        name: 'Dianne Russell',
        avatar: '👩🏻‍🎤',
        isOnline: false,
        lastMessage: 'Speaking of which, I saw an art e...',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    try {
      // Use batch write for better performance
      final batch = _firestore.batch();
      for (final friend in sampleFriends) {
        batch.set(_friendsCollection.doc(friend.id), friend.toFirestore());
      }
      
      await batch.commit();
      if (kDebugMode) print('✅ Sample friends batch write completed');
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing sample friends: $e');
    }
  }

  // Optimized methods with error handling
  Future<void> addFriend(Friend friend) async {
    if (_currentUserId.isEmpty) return;
    try {
      await _friendsCollection.doc(friend.id).set(friend.toFirestore());
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

  // Other methods remain the same...
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