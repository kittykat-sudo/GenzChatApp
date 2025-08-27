import 'package:chat_drop/features/friends/domain/models/friend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFriend(String userId, Friend friend) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friend.id)
        .set(friend.toMap());

    // Also add the reverse relationship
    final currentUser = await _firestore.collection('users').doc(userId).get();
    final currentUserName = currentUser.data()?['name'] ?? 'Unknown';

    final reverseFriend = Friend(
      id: userId,
      name: currentUserName,
      avatar: '😊', // Use avatar 
      status: FriendStatus.temporary,
      sessionId: friend.sessionId,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(friend.id)
        .collection('friends')
        .doc(userId)
        .set(reverseFriend.toMap());
  }

  Future<void> updateFriendStatus(
    String userId,
    String friendId,
    FriendStatus status, {
    String? requestedBy,
  }) async {
    final updateData = {'status': status.name, 'requestedBy': requestedBy};

    // Update both directions
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId)
        .update(updateData);

    await _firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(userId)
        .update(updateData);
  }

  Stream<String> getUserNameStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['name'] ?? 'Unknown User');
  }

  Stream<List<Friend>> getFriendsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final friends = <Friend>[];

          for (final doc in snapshot.docs) {
            try {
              final friendData = doc.data();

              // Get the latest name from the user's profile
              final userDoc =
                  await _firestore
                      .collection('users')
                      .doc(friendData['id'])
                      .get();

              final latestName =
                  userDoc.data()?['name'] ?? friendData['name'] ?? 'Unknown';

              // Update the name in friendData
              friendData['name'] = latestName;

              friends.add(Friend.fromMap(friendData));
            } catch (e) {
              print('Error parsing friend data: $e');
              // Return a fallback friend object
              friends.add(
                Friend(
                  id: doc.id,
                  name: doc.data()['name'] ?? 'Unknown',
                  avatar: doc.data()['avatar'] ?? '😊',
                  status: FriendStatus.temporary,
                  createdAt: DateTime.now(),
                ),
              );
            }
          }

          return friends;
        });
  }

  Future<Friend?> getFriend(String userId, String friendId) async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('friends')
              .doc(friendId)
              .get();

      if (!doc.exists) return null;
      return Friend.fromMap(doc.data()!);
    } catch (e) {
      print('Error getting friend: $e');
      return null;
    }
  }

  Future<void> updateLastMessage(
    String userId,
    String friendId,
    String message,
    DateTime timestamp,
  ) async {
    final updateData = {
      'lastMessage': message,
      'lastMessageTime': timestamp.toIso8601String(),
      'isRead': false, // Mark as unread when new message arrives
      'unreadCount': FieldValue.increment(1),
    };

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .update(updateData);
    } catch (e) {
      print('Error updating last message: $e');
    }
  }

  Future<void> markAsRead(String userId, String friendId) async {
    final updateData = {'isRead': true, 'unreadCount': 0};

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .update(updateData);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> removeFriend(String userId, String friendId) async {
    try {
      // Remove both directions
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .delete();

      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(userId)
          .delete();
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  // Add this method to your FriendsRemoteDataSource:

  Future<void> updateFriendName(
    String userId,
    String friendId,
    String newName,
  ) async {
    try {
      // Update in current user's friends collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .update({'name': newName});

      // Also update the friend's own user document
      await _firestore.collection('users').doc(friendId).update({
        'name': newName,
      });

      print('Updated friend name to: $newName');
    } catch (e) {
      print('Error updating friend name: $e');
    }
  }
}
