import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/utils/retro_snackbar.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:chat_drop/features/chat/domain/chat_session.dart';
import 'package:chat_drop/features/chat/presentation/providers/chat_providers.dart';
import 'package:chat_drop/features/chat/widgets/chat_footer_widget.dart';
import 'package:chat_drop/features/chat/widgets/chat_header_widget.dart';
import 'package:chat_drop/features/chat/widgets/chat_message_widget.dart';
import 'package:chat_drop/features/chat/widgets/friend_request_banner.dart';
import 'package:chat_drop/features/friends/presentation/providers/friends_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionId = ref.read(sessionIdProvider);
      if (sessionId != null) {
        // Mark all messages as read when opening chat
        _markMessagesAsRead(sessionId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead(String sessionId) {
    try {
      final chatActions = ref.read(chatActionsProvider);
      chatActions.markAllMessagesAsRead(sessionId);
      print('Marked all messages as read for session: $sessionId');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      final sessionId = ref.read(sessionIdProvider);
      if (sessionId != null) {
        ref.read(chatRepositoryProvider).sendMessage(sessionId, content);
        _messageController.clear();

        // Scroll to bottom after sending message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  void _handleClearChat() async {
    try {
      final sessionId = ref.read(sessionIdProvider);
      if (sessionId != null) {
        final chatActions = ref.read(chatActionsProvider);
        await chatActions.clearChatHistory(sessionId);

        // Force rebuild by invalidating the specific providers again
        ref.invalidate(messagesProvider(sessionId));

        if (mounted) {
          // This forces the widget to rebuild and re-read providers.
          setState(() {});

          showRetroSnackbar(
            context: context,
            message: "Chat history zapped! Fresh start unlocked.",
            type: SnackbarType.success,
          );
        } else {
          if (mounted) {
            showRetroSnackbar(
              context: context,
              message: "No active chat session to clear.",
              type: SnackbarType.error,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: 'Oops! Couldn’t clear the chat: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  void _handleRemoveFriend() async {
    try {
      final friendId = ref.read(currentChatFriendIdProvider);
      if (friendId != null) {
        final friendActions = ref.read(friendActionsProvider);
        await friendActions.removeFriend(friendId);

        // Clear session data
        ref.read(sessionIdProvider.notifier).state = null;
        ref.read(currentChatFriendIdProvider.notifier).state = null;

        if (mounted) {
          showRetroSnackbar(
            context: context,
            message: 'Friend removed — connection terminated!',
            type: SnackbarType.success,
          );

          // Navigate back to home
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: 'Failed to remove friend: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = ref.watch(sessionIdProvider);
    final sessionAsync =
        sessionId != null ? ref.watch(sessionProvider(sessionId)) : null;
    final messagesAsync =
        sessionId != null ? ref.watch(messagesProvider(sessionId)) : null;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // final currentFriendId = ref.watch(currentChatFriendIdProvider);
    final friendName = ref.watch(currentChatFriendNameProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ChatHeaderWidget(
        userName: friendName,
        lastSeen: 'Online',
        avatarEmoji: '😎',
        onClearChat: _handleClearChat,
        onRemoveFriend: _handleRemoveFriend,
      ),
      body: Column(
        children: [
          // Enhanced Friend request banner with better logic
          sessionAsync?.when(
                loading: () => const SizedBox.shrink(),
                error:
                    (err, stack) => Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.shade100,
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                    ),
                data: (session) {
                  if (session == null) return const SizedBox.shrink();

                  print("Session status: ${session.status}"); // Debug print
                  print("Current user ID: $currentUserId"); // Debug print
                  print(
                    "Session requested by: ${session.requestedBy}",
                  ); // Debug print

                  // Show "Send Friend Request" banner for temporary sessions
                  if (session.status == SessionStatus.temporary) {
                    return FriendRequestBanner(
                      message: 'Want to add $friendName as a permanent friend?',
                      buttonText: 'Send Request',
                      backgroundColor: AppColors.retroBlue,
                      onButtonPressed: () async {
                        try {
                          await ref
                              .read(chatRepositoryProvider)
                              .sendFriendRequest(sessionId!);
                          // Show success message
                          if (context.mounted) {
                            showRetroSnackbar(
                              context: context,
                              message: 'Friend request sent to $friendName!',
                              type: SnackbarType.success,
                            );
                          }
                        } catch (e) {
                          print('Failed to send friend request: $e');
                          if (context.mounted) {
                            showRetroSnackbar(
                              context: context,
                              message: 'Failed to send friend request: $e',
                              type: SnackbarType.error,
                            );
                          }
                        }
                      },
                    );
                  }

                  // Show "Accept/Reject" banner for pending requests received by current user
                  if (session.status == SessionStatus.pending &&
                      session.requestedBy != null &&
                      session.requestedBy != currentUserId) {
                    return FriendRequestBanner(
                      message: '$friendName sent you a friend request!',
                      buttonText: 'Accept',
                      secondaryButtonText: 'Reject',
                      backgroundColor: AppColors.retroTeal,
                      onButtonPressed: () async {
                        try {
                          await ref
                              .read(chatRepositoryProvider)
                              .acceptFriendRequest(sessionId!);
                          if (context.mounted) {
                            showRetroSnackbar(
                              context: context,
                              message: 'You are now friends with $friendName!',
                              type: SnackbarType.success,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showRetroSnackbar(
                              context: context,
                              message: 'Failed to send friend request: $e',
                              type: SnackbarType.error,
                            );
                          }
                        }
                      },
                      onSecondaryButtonPressed: () async {
                        try {
                          await ref
                              .read(chatRepositoryProvider)
                              .rejectFriendRequest(sessionId!);
                          if (context.mounted) {
                            showRetroSnackbar(
                              context: context,
                              message:
                                  'Friend request from $friendName rejected',
                              type: SnackbarType.error,
                            );
                          }
                        } catch (e) {
                          print('Failed to reject friend request: $e');
                        }
                      },
                    );
                  }

                  // Show "Request Sent" banner for pending requests sent by current user
                  if (session.status == SessionStatus.pending &&
                      session.requestedBy == currentUserId) {
                    return FriendRequestBanner(
                      message:
                          'Friend request sent to $friendName. Waiting for response...',
                      buttonText: 'Cancel Request',
                      backgroundColor: AppColors.retroOrange,
                      onButtonPressed: () async {
                        try {
                          await ref
                              .read(chatRepositoryProvider)
                              .rejectFriendRequest(sessionId!);
                          if (context.mounted) {
                            showRetroSnackbar(
                              context: context,
                              message: 'Friend request cancelled',
                              type: SnackbarType.error,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showRetroSnackbar(
                              context: context,
                              message: 'Failed to cancel friend request: $e',
                              type: SnackbarType.error,
                            );
                          }
                        }
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ) ??
              const SizedBox.shrink(),

          Container(height: 2, color: AppColors.border),

          // Messages list
          Expanded(
            child:
                messagesAsync?.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.errorRed,
                            ),
                            const SizedBox(height: 16),
                            Text('Error loading messages: $err'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (sessionId != null) {
                                  ref.invalidate(messagesProvider(sessionId));
                                }
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppColors.textGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Begin your conversation with $friendName!',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Type a note to get things rolling',
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      );
                    }

                    // Auto scroll to bottom when new messages arrive
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ChatMessageWidget(
                          message: message,
                          isMe: message.senderId == currentUserId,
                        );
                      },
                    );
                  },
                ) ??
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: AppColors.textGrey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No active chat session',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textGrey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scan a QR code to start chatting.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
          ),

          // Chat input footer
          ChatFooterWidget(
            messageController: _messageController,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
