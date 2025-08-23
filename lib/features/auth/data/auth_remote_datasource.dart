import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<String> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user!.uid;
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
}
