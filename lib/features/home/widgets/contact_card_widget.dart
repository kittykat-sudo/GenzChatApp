import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/widgets/user_avatar.dart'; // Add this import
import 'package:chat_drop/core/services/avatar_service.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String message;
  final String avatar; // Keep for backward compatibility
  final String? userId;
  final bool isOnline;
  final bool isRead;
  final int? unreadCount;
  final VoidCallback? onTap;

  const ContactCard({
    super.key,
    required this.name,
    required this.message,
    required this.avatar,
    this.userId,
    required this.isOnline,
    required this.isRead,
    this.unreadCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => context.push('/chat'),
        splashColor: AppColors.accentPink.withOpacity(0.6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 2.0,
            ),
            child: Row(
              children: [
                // Profile Picture with Online Status
                userId != null
                    ? UserAvatar(
                      userId: userId!,
                      userName: name,
                      size: 48,
                      showOnlineStatus: true,
                      isOnline: isOnline,
                      style: AvatarStyle.initials, // You can change this
                    )
                    : _buildFallbackAvatar(), // Fallback for backward compatibility

                const SizedBox(width: 12),

                // Name and Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              isRead ? AppColors.textGrey : AppColors.textDark,
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                if (unreadCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.border,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fallback avatar for backward compatibility
  Widget _buildFallbackAvatar() {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accentPink.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Center(
            child: Text(avatar, style: const TextStyle(fontSize: 24)),
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.onlineStatus,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.background, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
