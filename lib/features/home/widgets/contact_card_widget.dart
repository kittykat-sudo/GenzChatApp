import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String message;
  final String avatar;
  final bool isOnline;
  final bool isRead;
  final int? unreadCount;
  final VoidCallback? onTap;

  const ContactCard({
    super.key,
    required this.name,
    required this.message,
    required this.avatar,
    required this.isOnline,
    required this.isRead,
    this.unreadCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      decoration: BoxDecoration(
        color:
            unreadCount != null
                ? AppColors.primaryYellow.withOpacity(0.3)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.push('/chat'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Profile Picture with Online Status
                Stack(
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
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    // Online Status Indicator
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
                            border: Border(
                              top: BorderSide(
                                color: AppColors.background,
                                width: 2,
                              ),
                              right: BorderSide(
                                color: AppColors.background,
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: AppColors.background,
                                width: 2,
                              ),
                              left: BorderSide(
                                color: AppColors.background,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Name and Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
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

                // Unread Message Badge
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
                          blurRadius: 0,
                          spreadRadius: 0,
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
}
