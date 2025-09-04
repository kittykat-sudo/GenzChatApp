import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/widgets/retro_popup_menu.dart';
import 'package:chat_drop/core/widgets/retro_confirmation_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/widgets/user_avatar.dart'; // Add this import
import 'package:chat_drop/core/services/avatar_service.dart';

class ChatHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String lastSeen;
  final String avatarEmoji;
  final String? userId;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClearChat;
  final VoidCallback? onRemoveFriend;

  const ChatHeaderWidget({
    super.key,
    required this.userName,
    required this.lastSeen,
    required this.avatarEmoji,
    this.userId,
    this.onBackPressed,
    this.onClearChat,
    this.onRemoveFriend,
  });

  void _showPopupMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    RetroPopupMenu.show(
      context: context,
      position: RelativeRect.fromLTRB(
        position.right - 10,
        position.top + 50,
        0,
        position.bottom,
      ),
      width: 180,
      items: [
        RetroPopupMenuItem(
          text: 'Clear Chat',
          icon: Icons.delete_sweep_outlined,
          onTap: () => _handleClearChat(context),
        ),
        RetroPopupMenuItem(
          text: 'Remove Friend',
          icon: Icons.person_remove_outlined,
          textColor: AppColors.errorRed,
          iconColor: AppColors.errorRed,
          onTap: () => _handleRemoveFriend(context),
        ),
      ],
    );
  }

  void _handleClearChat(BuildContext context) {
    RetroConfirmationDialog.show(
      context: context,
      title: 'Wipe the Slate Clean?',
      message:
          'Poof! All messages with $userName will vanish into the pixel void. Once it’s gone, there’s no bringing it back!',
      confirmText: 'Zap It',
      cancelText: 'Keep It',
      confirmButtonColor: AppColors.accentPink,
      onConfirm: () {
        if (onClearChat != null) {
          onClearChat!();
        }
      },
    );
  }

  void _handleRemoveFriend(BuildContext context) {
    RetroConfirmationDialog.show(
      context: context,
      title: 'Pull the Plug on This Friendship?',
      message:
          'Remove $userName from your buddy list and erase your chat history. No rewinds, no second chances.',
      confirmText: 'Remove',
      cancelText: 'Nevermind',
      confirmButtonColor: AppColors.errorRed,
      onConfirm: () {
        if (onRemoveFriend != null) {
          onRemoveFriend!();
        }
      },
    );
  }

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
        onPressed: onBackPressed ?? () => context.go('/'),
      ),
      title: Row(
        children: [
          userId != null
              ? UserAvatar(
                userId: userId!,
                userName: userName,
                size: 40,
                showOnlineStatus: true,
                isOnline: true, // You can make this dynamic
                style: AvatarStyle.initials,
              )
              : _buildFallbackAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  lastSeen,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Builder(
            builder:
                (context) => InkWell(
                  onTap: () => _showPopupMenu(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.more_vert,
                      color: AppColors.textDark,
                      size: 24,
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
  }
  Widget _buildFallbackAvatar() {
    return Container(
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
