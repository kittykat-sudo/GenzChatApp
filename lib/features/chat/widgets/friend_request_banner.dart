import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FriendRequestBanner extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final Color backgroundColor;

  const FriendRequestBanner({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.backgroundColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: backgroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (onSecondaryButtonPressed != null &&
              secondaryButtonText != null) ...[
            TextButton(
              onPressed: onSecondaryButtonPressed,
              child: Text(
                secondaryButtonText!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
