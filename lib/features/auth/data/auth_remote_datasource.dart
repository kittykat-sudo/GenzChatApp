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
}
