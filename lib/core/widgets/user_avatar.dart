import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/services/avatar_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final String userName;
  final double size;
  final bool showOnlineStatus;
  final bool isOnline;
  final AvatarStyle style;
  final bool hasBorder;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.userName,
    this.size = 48,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.style = AvatarStyle.initials,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                hasBorder
                    ? Border.all(color: AppColors.border, width: 2)
                    : null,
            boxShadow:
                hasBorder
                    ? [
                      BoxShadow(
                        color: AppColors.border.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ]
                    : null,
          ),
          child: ClipOval(child: _buildAvatarContent()),
        ),

        // Online status indicator
        if (showOnlineStatus)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.onlineStatus : AppColors.textGrey,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    switch (style) {
      case AvatarStyle.initials:
        return _buildInitialsAvatar();
      case AvatarStyle.dicebear:
      case AvatarStyle.boring:
        return _buildNetworkAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    final avatarData = AvatarService.generateAvatar(userId, userName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarData.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          avatarData.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            fontFamily: "ZillaSlab",
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkAvatar() {
    final avatarUrl = AvatarService.getAvatarUrl(userId, style: style);

    return CachedNetworkImage(
      imageUrl: avatarUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildInitialsAvatar(),
      errorWidget: (context, url, error) => _buildInitialsAvatar(),
    );
  }
}
