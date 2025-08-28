import 'package:chat_drop/features/auth/data/auth_remote_datasource.dart';
import 'package:chat_drop/features/auth/data/auth_repository_impl.dart';
import 'package:chat_drop/features/auth/domain/auth_repository.dart';
import 'package:chat_drop/features/friends/presentation/providers/friends_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDatasource());
});

// ADD THESE MISSING PROVIDERS
final sessionIdProvider = StateProvider<String?>((ref) => null);
final currentChatFriendIdProvider = StateProvider<String?>((ref) => null);

// Create session provider for QR generator
final createSessionProvider = FutureProvider<String>((ref) async {
  final authActions = ref.read(authActionsProvider);
  return await authActions.createSession();
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user name provider
final currentUserNameProvider = FutureProvider<String?>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);
  return await authRepository.getCurrentUserName();
});

// Current user name stream provider (for real-time updates)
final currentUserNameStreamProvider = StreamProvider<String?>((ref) async* {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    yield null;
    return;
  }

  final authRepository = ref.read(authRepositoryProvider);
  yield await authRepository.getCurrentUserName();

  // Listen for changes in the user document
  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data()?['name'] as String?);
});

// Auth actions provider
final authActionsProvider = Provider((ref) => AuthActions(ref));

class AuthActions {
  final Ref _ref;
  AuthActions(this._ref);

  Future<UserCredential> signInAnonymously() async {
    final repository = _ref.read(authRepositoryProvider);
    final result = await repository.signInAnonymously();

    // Invalidate providers to refresh after sign in
    _ref.invalidate(currentUserProvider);
    _ref.invalidate(currentUserNameProvider);

    return result;
  }

  Future<String> createSession() async {
    final repository = _ref.read(authRepositoryProvider);
    return await repository.createSession();
  }

  Future<void> joinSession(String sessionId) async {
    final repository = _ref.read(authRepositoryProvider);
    await repository.joinSession(sessionId);
  }

  Future<void> registerUserName(String name) async {
    final repository = _ref.read(authRepositoryProvider);
    await repository.registerUserName(name);

    // Invalidate providers to refresh after name registration
    _ref.invalidate(currentUserNameProvider);
    _ref.invalidate(currentUserNameStreamProvider);
  }

  Future<void> updateUserName(String name) async {
    final repository = _ref.read(authRepositoryProvider);
    await repository.updateUserName(name);

    // Invalidate providers to refresh after name update
    _ref.invalidate(currentUserNameProvider);
    _ref.invalidate(currentUserNameStreamProvider);

    // Also invalidate friends providers since friend names might have changed
    _ref.invalidate(friendsStreamProvider);
  }
}
