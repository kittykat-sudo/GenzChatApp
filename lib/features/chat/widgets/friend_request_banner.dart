import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FriendRequestBanner extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const FriendRequestBanner({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryYellow,
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textDark),
            ),
          ),
          ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText)),
        ],
      ),
    );
  }
}
