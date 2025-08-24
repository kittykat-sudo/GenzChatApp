import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class ChatHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String lastSeen;
  final String avatarEmoji;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;

  const ChatHeaderWidget({
    super.key,
    required this.userName,
    required this.lastSeen,
    required this.avatarEmoji,
    this.onBackPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: -15,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textDark,
            size: 20,
          ),
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentPink.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Center(
              child: Text(avatarEmoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                lastSeen,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: onMenuPressed,
            child: const Icon(
              Icons.more_horiz,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
