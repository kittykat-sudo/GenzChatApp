import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Sign in anonymously and return full usercredential
  Future<UserCredential> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential;
  }

  Future<String> createSession() async {
    final sessionId = _uuid.v4();
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('session').doc(sessionId).set({
        'user': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return sessionId;
  }

  Future<void> joinSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('session').doc(sessionId).update({
        'users': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  // Set user's name to annonymous registered user.
  Future<void> registerUserName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Update FirebaseAuth displayName
      await user.updateDisplayName(name);

      // Save user info in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'uid': user.uid,
      });

      // For debug
      print("✅ Registered User -> ID: ${user.uid}, Name: $name");
    }
  }

  // Update user's name
  Future<void> updateUserName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Update FirebaseAuth displayName
      await user.updateDisplayName(name);

      // Update user info in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update name in all friend relationships where this user appears
      await _updateNameInFriendRelationships(user.uid, name);

      print("✅ Updated User Name -> ID: ${user.uid}, Name: $name");
    } catch (e) {
      print("❌ Failed to update user name: $e");
      rethrow;
    }
  }

  // Helper method to update name in friend relationships
  Future<void> _updateNameInFriendRelationships(
    String userId,
    String newName,
  ) async {
    try {
      // Get all users who have this user as a friend
      final usersQuery = await _firestore.collection('users').get();

      final batch = _firestore.batch();

      for (final userDoc in usersQuery.docs) {
        // Check if this user has the current user as a friend
        final friendDoc =
            await userDoc.reference.collection('friends').doc(userId).get();

        if (friendDoc.exists) {
          // Update the friend's name in this user's friends collection
          batch.update(friendDoc.reference, {'name': newName});
        }
      }

      await batch.commit();
      print("✅ Updated name in friend relationships");
    } catch (e) {
      print("❌ Failed to update name in friend relationships: $e");
      // Don't rethrow here - name update should still succeed even if friend updates fail
    }
  }

  // Get current user's name
  Future<String?> getCurrentUserName() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] as String?;
      }
      return user.displayName;
    } catch (e) {
      print("❌ Failed to get current user name: $e");
      return user.displayName;
    }
  }
}
