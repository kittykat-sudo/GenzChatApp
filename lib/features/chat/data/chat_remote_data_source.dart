import 'package:chat_drop/features/chat/data/message_model.dart';
import 'package:chat_drop/features/chat/data/session_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new session
  Future<String> createSession(String currentUserId, String userName) async {
    final sessionDoc = _firestore.collection('sessions').doc();

    final sessionData = {
      'users': [currentUserId],
      'status': 'temporary',
      'createdAt': FieldValue.serverTimestamp(),
      'userNames': {currentUserId: userName},
      'requestedBy': null,
    };

    await sessionDoc.set(sessionData);
    return sessionDoc.id;
  }

  // Join an existing session
  Future<void> joinSession(
    String sessionId,
    String userId,
    String userName,
  ) async {
    final sessionRef = _firestore.collection('sessions').doc(sessionId);

    await sessionRef.update({
      'users': FieldValue.arrayUnion([userId]),
      'userNames.$userId': userName,
    });
  }

  // Send a message
  Future<void> sendMessage(MessageModel message) async {
    await _firestore
        .collection('sessions')
        .doc(message.sessionId)
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
  }

  // Send friend request
  Future<void> sendFriendRequest(String sessionId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'pending',
      'requestedBy': currentUserId,
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'permanent',
    });
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'temporary',
      'requestedBy': null,
    });
  }

  // Get session stream
  Stream<SessionModel?> getSession(String sessionId) {
    return _firestore.collection('sessions').doc(sessionId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return SessionModel.fromFirestore(doc);
    });
  }

  // Get session once (for getting friend name)
  Future<SessionModel?> getSessionOnce(String sessionId) async {
    final doc = await _firestore.collection('sessions').doc(sessionId).get();
    if (!doc.exists) return null;
    return SessionModel.fromFirestore(doc);
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessages(String sessionId) {
    return _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  // Mark message as read
  Future<void> markAsRead(String sessionId, String messageId) async {
    await _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  // Get all sessions for a user (for friends list)
  Stream<List<SessionModel>> getUserSessions(String userId) {
    return _firestore
        .collection('sessions')
        .where('users', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SessionModel.fromFirestore(doc))
              .toList();
        });
  }

  // Check if session exists
  Future<bool> sessionExists(String sessionId) async {
    final doc = await _firestore.collection('sessions').doc(sessionId).get();
    return doc.exists;
  }

  // Add these methods to your ChatRemoteDataSource:

  Future<void> markMessageAsRead(String messageId) async {
    final sessionsQuery = await _firestore.collection('sessions').get();

    for (final sessionDoc in sessionsQuery.docs) {
      try {
        await sessionDoc.reference.collection('messages').doc(messageId).update(
          {'isRead': true, 'readAt': FieldValue.serverTimestamp()},
        );
        break;
      } catch (e) {
        continue;
      }
    }
  }

  Future<void> markAllMessagesAsRead(String sessionId, String userId) async {
    try {
      // Get all messages in the session first (without complex query)
      final messagesQuery =
          await _firestore
              .collection('sessions')
              .doc(sessionId)
              .collection('messages')
              .get();

      final batch = _firestore.batch();
      int updateCount = 0;

      // Filter and update in memory to avoid complex Firestore query
      for (final doc in messagesQuery.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        final isRead = data['isRead'] as bool? ?? false;

        // Only update messages from other users that are not read
        if (senderId != null && senderId != userId && !isRead) {
          batch.update(doc.reference, {'isRead': true});
          updateCount++;
        }
      }

      if (updateCount > 0) {
        await batch.commit();
        print('Marked $updateCount messages as read');
      } else {
        print('No messages to mark as read');
      }
    } catch (e) {
      print('Error in markAllMessagesAsRead: $e');
      rethrow;
    }
  }

  Future<void> markMessageAsDelivered(String messageId) async {
    final sessionsQuery = await _firestore.collection('sessions').get();

    for (final sessionDoc in sessionsQuery.docs) {
      try {
        await sessionDoc.reference.collection('messages').doc(messageId).update(
          {'isSent': true, 'deliveredAt': FieldValue.serverTimestamp()},
        );
        break;
      } catch (e) {
        continue;
      }
    }
  }

  Future<void> updateMessageReadStatus(String messageId, bool isRead) async {
    final sessionsQuery = await _firestore.collection('sessions').get();

    for (final sessionDoc in sessionsQuery.docs) {
      try {
        await sessionDoc.reference.collection('messages').doc(messageId).update(
          {
            'isRead': isRead,
            if (isRead) 'readAt': FieldValue.serverTimestamp(),
          },
        );
        break;
      } catch (e) {
        continue;
      }
    }
  }

  Future<List<MessageModel>> getLastMessage(String sessionId) async {
    final querySnapshot =
        await _firestore
            .collection('sessions')
            .doc(sessionId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    return querySnapshot.docs.map((doc) {
      return MessageModel.fromFirestore(doc);
    }).toList();
  }

  Future<void> clearChatHistory(String sessionId) async {
    try {
      print("Starting to clear chat history for session: $sessionId");

      final messageQuery =
          await _firestore
              .collection('sessions')
              .doc(sessionId)
              .collection('messages')
              .get();

      print('Found ${messageQuery.docs.length} messages to delete');

      // Delete messages in batches (Firestore has a limit of 500 operations per batch)
      const batchSize = 500;
      final totalDocs = messageQuery.docs.length;

      for (int i = 0; i < totalDocs; i += batchSize) {
        final batch = _firestore.batch();
        final endIndex =
            (i + batchSize > totalDocs) ? totalDocs : i + batchSize;

        for (int j = i; j < endIndex; j++) {
          batch.delete(messageQuery.docs[j].reference);
        }

        await batch.commit();
        print(
          'Deleted batch ${(i ~/ batchSize) + 1} of ${(totalDocs / batchSize).ceil()}',
        );
      }
      print('Successfully cleared chat history for session: $sessionId');
    } catch (e) {
      print('Error clearing chat history: $e');
      rethrow;
    }
  }
}
