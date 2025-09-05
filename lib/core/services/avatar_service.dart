import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AvatarService {
  static const List<Color> _avatarColors = [
    Color(0xFF00FF9C), // Neon Green
    Color(0xFFFF6EC7), // Hot Pink
    Color(0xFFFFD300), // Bright Yellow
    Color(0xFF00BFFF), // Electric Blue
    Color(0xFFFF5F1F), // Vivid Orange
    Color(0xFFB200FF), // Deep Purple
    Color(0xFF39FF14), // Laser Lime
    Color(0xFFFF073A), // Crimson Red
  ];

  static const List<IconData> _avatarIcons = [
    Icons.person,
    Icons.face,
    Icons.account_circle,
    Icons.sentiment_satisfied,
    Icons.mood,
    Icons.emoji_emotions,
    Icons.psychology,
    Icons.self_improvement,
  ];

  /// Generate a consistent avatar based on user ID
  static AvatarData generateAvatar(String userId, String userName) {
    // Use user ID for consistent color/icon selection
    final hash = md5.convert(utf8.encode(userId)).toString();
    final colorIndex =
        int.parse(hash.substring(0, 1), radix: 16) % _avatarColors.length;
    final iconIndex =
        int.parse(hash.substring(1, 2), radix: 16) % _avatarIcons.length;

    return AvatarData(
      backgroundColor: _avatarColors[colorIndex],
      icon: _avatarIcons[iconIndex],
      initials: _getInitials(userName),
    );
  }

  /// Generate initials from user name
  static String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  /// Get avatar URL from various services (optional)
  static String getAvatarUrl(
    String userId, {
    AvatarStyle style = AvatarStyle.initials,
  }) {
    switch (style) {
      case AvatarStyle.initials:
        return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userId)}&background=random&color=fff&size=128';
      case AvatarStyle.dicebear:
        return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$userId';
      case AvatarStyle.boring:
        return 'https://source.boringavatars.com/beam/120/$userId?colors=264653,f4a261,e76f51,e9c46a,2a9d8f';
    }
  }
}

enum AvatarStyle { initials, dicebear, boring }

class AvatarData {
  final Color backgroundColor;
  final IconData icon;
  final String initials;

  AvatarData({
    required this.backgroundColor,
    required this.icon,
    required this.initials,
  });
}
