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

  Future<void> markAllMessagesAsRead(
    String sessionId,
    String currentUserId,
  ) async {
    final messagesQuery =
        await _firestore
            .collection('sessions')
            .doc(sessionId)
            .collection('messages')
            .where('senderId', isNotEqualTo: currentUserId)
            .where('isRead', isEqualTo: false)
            .get();

    final batch = _firestore.batch();

    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
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
}
