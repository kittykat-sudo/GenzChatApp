import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';

class ChatFooterWidget extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onMicPressed;

  const ChatFooterWidget({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    this.onAttachmentPressed,
    this.onMicPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Row(
        children: [
          // Attachment button
          RetroButton(
            text: '',
            icon: Icons.attach_file,
            onPressed: onAttachmentPressed ?? () {},
            backgroundColor: AppColors.primaryYellow,
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 12),
          // Message input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.border, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontFamily: "ZillaSlab",
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type Messages......',
                        hintStyle: TextStyle(
                          color: AppColors.textGrey,
                          fontFamily: "ZillaSlab",
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => onSendMessage(),
                    ),
                  ),
                  // Microphone button
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: onMicPressed,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.mic,
                          color: AppColors.textDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          RetroButton(
            text: '',
            icon: Icons.send,
            onPressed: onSendMessage,
            backgroundColor: AppColors.accentPink,
            width: 48,
            height: 48,
          ),
        ],
      ),
    );
  }
}
