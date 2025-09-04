import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class RetroPlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isMe;
  final VoidCallback onTap;
  final double size;

  const RetroPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.isMe,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // Retro gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isMe
                    ? [
                      AppColors.accentPink,
                      AppColors.accentPink.withOpacity(0.8),
                    ]
                    : [
                      AppColors.retroTeal,
                      AppColors.retroTeal.withOpacity(0.8),
                    ],
          ),
          shape: BoxShape.circle,
          // Retro border with multiple layers
          border: Border.all(color: AppColors.border, width: 2),
          // Retro shadow effect
          boxShadow: [
            // Main shadow
            BoxShadow(
              color: AppColors.border,
              offset: const Offset(3, 3),
              blurRadius: 0,
              spreadRadius: 0,
            ),
            // Inner highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: const Offset(-1, -1),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Retro inner circle for depth
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isMe
                            ? Colors.white.withOpacity(0.2)
                            : AppColors.retroOrange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Play/Pause Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isMe ? AppColors.textDark : Colors.white,
                  size: size * 0.45, // Scale icon with button size
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Retro shine effect
            Positioned(
              top: size * 0.14, // Scale shine position
              left: size * 0.14,
              child: Container(
                width: size * 0.18, // Scale shine size
                height: size * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
