import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) const SizedBox(width: 0),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              minWidth: 60,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    message.isMe
                        ? AppColors.accentPink
                        : AppColors.primaryYellow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      message.isMe
                          ? const Radius.circular(12)
                          : const Radius.circular(4),
                  bottomRight:
                      message.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(12),
                ),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child:
                  message.isVoice ? _buildVoiceMessage() : _buildTextMessage(),
            ),
          ),
          if (message.isMe) const SizedBox(width: 0),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.graphic_eq, color: AppColors.textDark, size: 20),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.textDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(painter: VoiceWavePainter()),
        ),
      ],
    );
  }

  Widget _buildTextMessage() {
    return Text(
      message.text,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textDark,
        fontFamily: "ZillaSlab",
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isVoice;

  ChatMessage({required this.text, required this.isMe, this.isVoice = false});
}

class VoiceWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textDark
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final heights = [8, 4, 12, 6, 10, 3, 8, 5, 11, 7, 9, 4, 6, 8, 5];
    final spacing = size.width / heights.length;

    for (int i = 0; i < heights.length; i++) {
      final x = i * spacing + spacing / 2;
      final height = heights[i].toDouble();
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
