import 'package:chat_drop/core/services/auth_state_manager.dart';
import 'package:chat_drop/features/auth/data/auth_remote_datasource.dart';
import 'package:chat_drop/features/auth/data/auth_repository_impl.dart';
import 'package:chat_drop/features/auth/domain/auth_repository.dart';
// import 'package:chat_drop/features/friends/presentation/providers/friends_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDatasource());
});

// PROVIDERS
final sessionIdProvider = StateProvider<String?>((ref) => null);
final currentChatFriendIdProvider = StateProvider<String?>((ref) => null);

// Login state provider
final isLoggedInProvider = StateProvider<bool>((ref) => false);

// Persistent auth state provider
final authStateProvider = FutureProvider<bool>((ref) async {
  final isLoggedIn = await AuthStateManager.isLoggedIn();
  // Update the state provider
  ref.read(isLoggedInProvider.notifier).state = isLoggedIn;
  return isLoggedIn;
});

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

  // Future<void> updateUserName(String name) async {
  //   final repository = _ref.read(authRepositoryProvider);
  //   await repository.updateUserName(name);

  //   // Invalidate providers to refresh after name update
  //   _ref.invalidate(currentUserNameProvider);
  //   _ref.invalidate(currentUserNameStreamProvider);

  //   // Also invalidate friends providers since friend names might have changed
  //   _ref.invalidate(friendsStreamProvider);
  // }

  Future<void> completeNameRegistration(String name) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No authenticated user');

      // Update name in Firestore
      await _ref.read(authRepositoryProvider).updateUserName(name);

      // Save login state
      await AuthStateManager.saveUserData(
        userName: name,
        userId: currentUser.uid,
      );

      // Update provider state
      _ref.read(isLoggedInProvider.notifier).state = true;

      print('✅ Name registration completed and login state saved');
    } catch (e) {
      print('❌ Failed to complete name registration: $e');
      rethrow;
    }
  }

  Future<void> updateUserName(String newName) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No authenticated user');

      // Update name in Firestore
      await _ref.read(authRepositoryProvider).updateUserName(newName);

      // Update saved user data
      await AuthStateManager.saveUserData(
        userName: newName,
        userId: currentUser.uid,
      );

      print('✅ User name updated and saved locally');
    } catch (e) {
      print('❌ Failed to update user name: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear local auth data
      await AuthStateManager.clearAuthData();

      // Update provider state
      _ref.read(isLoggedInProvider.notifier).state = false;

      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Failed to logout: $e');
      rethrow;
    }
  }

  // Auto-login for returning users
  Future<void> autoLogin() async {
    try {
      final isLoggedIn = await AuthStateManager.isLoggedIn();

      if (isLoggedIn) {
        final userData = await AuthStateManager.getUserData();
        final savedUserId = userData['userId'];
        final currentUser = FirebaseAuth.instance.currentUser;

        // Verify Firebase auth state matches saved state
        if (currentUser != null && currentUser.uid == savedUserId) {
          _ref.read(isLoggedInProvider.notifier).state = true;
          print('✅ Auto-login successful');
        } else {
          // Clear invalid auth data
          await AuthStateManager.clearAuthData();
          _ref.read(isLoggedInProvider.notifier).state = false;
          print('⚠️ Auth state mismatch - cleared saved data');
        }
      }
    } catch (e) {
      print('❌ Auto-login failed: $e');
      await AuthStateManager.clearAuthData();
      _ref.read(isLoggedInProvider.notifier).state = false;
    }
  }
}
