import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:chat_drop/features/chat/presentation/providers/chat_providers.dart';
import 'package:chat_drop/features/friends/domain/models/friend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/features/home/widgets/contact_card_widget.dart';
import 'package:chat_drop/features/friends/presentation/providers/friends_providers.dart';
import 'dart:convert'; // Add this import

class ContactListWidget extends ConsumerWidget {
  const ContactListWidget({super.key});

  // Helper method to format last message for display
  String _formatLastMessage(String? lastMessage, String friendId, String? currentUserId) {
    if (lastMessage == null || lastMessage.isEmpty) {
      return 'No messages yet';
    }

    // Check if it's a voice message (JSON format)
    try {
      final messageData = jsonDecode(lastMessage);
      if (messageData['type'] == 'voice') {
        // Determine if it's sent or received based on some logic
        // You might need to add senderId to your Friend model for better detection
        return '🎤 Voice message';
      }
    } catch (e) {
      // Not JSON, treat as regular text message
    }

    // Return regular text message (truncated if too long)
    if (lastMessage.length > 30) {
      return '${lastMessage.substring(0, 30)}...';
    }
    
    return lastMessage;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the real-time provider instead
    final friendsAsync = ref.watch(friendsWithLiveMessagesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Friends Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Friends', style: AppTextStyles.heading),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: friendsAsync.when(
              data: (friends) {
                if (friends.isEmpty) {
                  return const _EmptyFriendsState();
                }

                // Debug print to see real-time updates
                print('📱 Contact list updated: ${friends.length} friends');
                for (final friend in friends) {
                  print(
                    '  ${friend.name}: ${friend.unreadCount} unread, "${friend.lastMessage}"',
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 200,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    
                    // Format the last message for display
                    final displayMessage = _formatLastMessage(
                      friend.lastMessage, 
                      friend.id, 
                      currentUserId
                    );

                    return ContactCard(
                      key: ValueKey(
                        '${friend.id}_${friend.unreadCount}_${friend.lastMessage}',
                      ),
                      name: friend.name,
                      message: displayMessage, // Use formatted message
                      avatar: friend.avatar ?? '😊',
                      isOnline: friend.isOnline, // Real online status
                      isRead: friend.isRead, // Real read status
                      unreadCount:
                          friend.unreadCount > 0
                              ? friend.unreadCount
                              : null, // Real unread count
                      onTap: () => _handleFriendTap(ref, friend, context),
                    );
                  },
                );
              },
              loading: () => const _LoadingState(),
              error:
                  (error, stack) => _ErrorState(
                    error: error,
                    onRetry:
                        () => ref.invalidate(friendsWithLiveMessagesProvider),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFriendTap(WidgetRef ref, Friend friend, BuildContext context) {
    // Use microtask to avoid blocking UI
    Future.microtask(() {
      try {
        // Cache the friend name immediately
        final nameCache = ref.read(friendNameCacheProvider.notifier);
        nameCache.update((cache) => {...cache, friend.id: friend.name});

        print("Cached friend name: ${friend.name} for ID: ${friend.id}");

        // Mark friend as read
        ref.read(friendActionsProvider).markAsRead(friend.id);

        // Set the session ID if available
        if (friend.sessionId != null) {
          ref.read(sessionIdProvider.notifier).state = friend.sessionId;
        }

        // store the friend ID for the chat screen
        ref.read(currentChatFriendIdProvider.notifier).state = friend.id;

        print("Setting session ID: ${friend.sessionId}");
        print("Setting friend ID: ${friend.id}");
      } catch (e) {
        if (kDebugMode) print('Error handling friend tap: $e');
      }
    });

    context.push('/chat');
  }
}

// Keep your existing _EmptyFriendsState, _LoadingState, and _ErrorState widgets...
class _EmptyFriendsState extends StatelessWidget {
  const _EmptyFriendsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No friends yet!',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan a QR code to add friends!',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/qr-scanner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircularProgressIndicator(
              color: AppColors.accentPink,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading friends...',
              style: TextStyle(color: AppColors.textGrey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print('Friends stream error: $error');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong!',
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.toString()}',
              style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}