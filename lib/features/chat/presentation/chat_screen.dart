import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/features/chat/widgets/chat_header_widget.dart';
import 'package:chat_drop/features/chat/widgets/chat_message_widget.dart';
import 'package:chat_drop/features/chat/widgets/chat_footer_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hey bro!", isMe: false),
    ChatMessage(text: "What sup?", isMe: true),
    ChatMessage(
      text: "Lately I'm learning about an art style called Retro",
      isMe: false,
    ),
    ChatMessage(
      text:
          "While the main vintage color tones are deep, warm colors, the Retro style is more colorful when the main color tones are pastel.",
      isMe: false,
    ),
    ChatMessage(text: "Wow look great!", isMe: true),
    ChatMessage(text: "🎵 [Voice message]", isMe: true, isVoice: true),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Don't forget to dispose ScrollController
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(text: _messageController.text.trim(), isMe: true),
        );
        _messageController.clear();
      });

      // Auto-scroll to bottom after adding new message
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Add a small delay to ensure the ListView has updated
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

  void _handleAttachment() {
    // Implement attachment functionality
    print('Attachment pressed');
  }

  void _handleMicrophone() {
    // Implement voice recording functionality
    print('Microphone pressed');
  }

  void _handleMenu() {
    // Implement menu functionality
    print('Menu pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ChatHeaderWidget(
        userName: 'Kristin Watson',
        lastSeen: 'Online 7m ago',
        avatarEmoji: '👩🏻‍💼',
        onMenuPressed: _handleMenu,
      ),
      body: Column(
        children: [
          // Divider
          Container(height: 2, color: AppColors.border),
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Add controller to ListView
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageWidget(message: message);
              },
            ),
          ),
          // Message input footer
          ChatFooterWidget(
            messageController: _messageController,
            onSendMessage: _sendMessage,
            onAttachmentPressed: _handleAttachment,
            onMicPressed: _handleMicrophone,
          ),
        ],
      ),
    );
  }
}
