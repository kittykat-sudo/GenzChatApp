import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/features/auth/presentation/providers/auth_providers.dart';
import 'package:chat_drop/features/chat/domain/chat_session.dart';
import 'package:chat_drop/features/chat/presentation/providers/chat_providers.dart';
import 'package:chat_drop/features/chat/widgets/chat_footer_widget.dart';
import 'package:chat_drop/features/chat/widgets/chat_header_widget.dart';
import 'package:chat_drop/features/chat/widgets/chat_message_widget.dart';
import 'package:chat_drop/features/chat/widgets/friend_request_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    } catch (e) {
      print('Failed to mark messages as read: $e');
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

  @override
  Widget build(BuildContext context) {
    final sessionId = ref.watch(sessionIdProvider);
    final sessionAsync =
        sessionId != null ? ref.watch(sessionProvider(sessionId)) : null;
    final messagesAsync =
        sessionId != null ? ref.watch(messagesProvider(sessionId)) : null;
    final friendNameAsync = ref.watch(currentChatFriendNameProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final currentFriendId = ref.watch(currentChatFriendIdProvider);

    // Debug prints
    print("Session ID: $sessionId");
    print("Current Friend ID: $currentFriendId");

    // Get friend name from provider
    String friendName = 'Friend';
    friendNameAsync.when(
      data: (name) {
        friendName = name;
        print("Friend Name from provider: $name");
      },
      loading: () {
        friendName = 'Loading...';
        print("Friend Name: Loading...");
      },
      error: (err, stack) {
        print('Error loading friend name: $err');
        friendName = 'Unknown';
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ChatHeaderWidget(
        userName: friendName,
        lastSeen: 'Online',
        avatarEmoji: '😊',
      ),
      body: Column(
        children: [
          // Friend request banner
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

                  if (session.status == SessionStatus.temporary) {
                    return FriendRequestBanner(
                      message: 'Want to add $friendName as a permanent friend?',
                      buttonText: 'Send Request',
                      onButtonPressed: () {
                        ref
                            .read(chatRepositoryProvider)
                            .sendFriendRequest(sessionId!);
                      },
                    );
                  }
                  if (session.status == SessionStatus.pending &&
                      session.requestedBy != currentUserId) {
                    return FriendRequestBanner(
                      message: '$friendName sent you a friend request!',
                      buttonText: 'Accept',
                      onButtonPressed: () {
                        ref
                            .read(chatRepositoryProvider)
                            .acceptFriendRequest(sessionId!);
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
                              'Start chatting with $friendName!',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Send a message to begin the conversation.',
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
