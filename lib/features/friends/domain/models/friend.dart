class Friend {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isRead;

  const Friend({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isOnline,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isRead = true,
  });

  factory Friend.fromFirestore(Map<String, dynamic> data, String id) {
    return Friend(
      id: id,
      name: data['name'] ?? '',
      avatar: data['avatar'] ?? '👤',
      isOnline: data['isOnline'] ?? false,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        data['lastMessageTime'] ?? 0,
      ),
      unreadCount: data['unreadCount'] ?? 0,
      isRead: data['isRead'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
      'isRead': isRead,
    };
  }

  Friend copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isOnline,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isRead,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isRead: isRead ?? this.isRead,
    );
  }
}