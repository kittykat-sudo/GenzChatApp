import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/theme/app_text_styles.dart';

class ContactListWidget extends StatelessWidget {
  const ContactListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.accentPink,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/qr'),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: AppColors.textDark,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Friends Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Friends',
              style: AppTextStyles.subHeading,
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              children: [
                _buildContactItem(
                  context: context,
                  name: 'Marvin McKinney',
                  message: 'Hey, have you noticed how much...',
                  avatar: '🧑🏿‍💼',
                  isOnline: true,
                  isRead: true,
                ),
                _buildContactItem(
                  context: context,
                  name: 'Wade Warren',
                  message: 'Absolutely! It\'s fascinating how p...',
                  avatar: '🧑🏼‍💼',
                  isOnline: true,
                  isRead: true,
                ),
                _buildContactItem(
                  context: context,
                  name: 'Eleanor Pena',
                  message: 'Hey, have you noticed how...',
                  avatar: '👨🏻‍💼',
                  isOnline: true,
                  unreadCount: 2,
                  isRead: false,
                ),
                _buildContactItem(
                  context: context,
                  name: 'Jane Cooper',
                  message: 'I think it\'s great. The vibrant...',
                  avatar: '👩🏽‍🎨',
                  isOnline: false,
                  unreadCount: 2,
                  isRead: false,
                ),
                _buildContactItem(
                  context: context,
                  name: 'Kristin Watson',
                  message: 'It\'s like a never-ending groove.',
                  avatar: '👩🏻‍💼',
                  isOnline: true,
                  isRead: true,
                ),
                _buildContactItem(
                  context: context,
                  name: 'Dianne Russell',
                  message: 'Speaking of which, I saw an art e...',
                  avatar: '👩🏻‍🎤',
                  isOnline: false,
                  isRead: true,
                ),

                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Group',
                    style: AppTextStyles.subHeading,
                  ),
                ),

                const SizedBox(height: 16),

                _buildContactItem(
                  context: context,
                  name: 'Artistic Visions',
                  message: 'Hey, have you noticed how much...',
                  avatar: '🎨',
                  isOnline: false,
                  isRead: true,
                ),
                _buildContactItem(
                  context: context,
                  name: 'Retro Renaissance',
                  message: 'Absolutely! It\'s fascinating how p...',
                  avatar: '🏛️',
                  isOnline: false,
                  isRead: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required String name,
    required String message,
    required String avatar,
    required bool isOnline,
    required bool isRead,
    int? unreadCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: unreadCount != null ? AppColors.primaryYellow.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/chat'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
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
                            border: Border(
                              top: BorderSide(color: AppColors.background, width: 2),
                              right: BorderSide(color: AppColors.background, width: 2),
                              bottom: BorderSide(color: AppColors.background, width: 2),
                              left: BorderSide(color: AppColors.background, width: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isRead ? AppColors.textDark : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isRead ? AppColors.textGrey : AppColors.textDark,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                if (unreadCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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