import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  // Signs in the user annonymously and returns their unique ID.
  Future<UserCredential> signInAnonymously();

  // Create a new chat session in the backend and returns the session ID.
  Future<String> createSession();

  // Joins an existing chat session using a session ID from a QR code.
  Future<void> joinSession(String sessionId);

  // Register a user with a name annonymously
  Future<void> registerUserName(String name);
}