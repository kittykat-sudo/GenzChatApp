enum FriendStatus { temporary, pending, permanent }

class Friend {
  final String id;
  final String name;
  final String? avatar;
  final FriendStatus status;
  final String? sessionId;
  final DateTime createdAt;
  final String? requestedBy;
  final DateTime? lastMessageTime;
  final String? lastMessage;
  final bool isOnline;
  final bool isRead;
  final int unreadCount;

  Friend({
    required this.id,
    required this.name,
    this.avatar,
    required this.status,
    this.sessionId,
    required this.createdAt,
    this.requestedBy,
    this.lastMessageTime,
    this.lastMessage,
    this.isOnline = false,
    this.isRead = true,
    this.unreadCount = 0,
  });

  Friend copyWith({
    String? id,
    String? name,
    String? avatar,
    FriendStatus? status,
    String? sessionId,
    DateTime? createdAt,
    String? requestedBy,
    DateTime? lastMessageTime,
    String? lastMessage,
    bool? isOnline,
    bool? isRead,
    int? unreadCount,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      requestedBy: requestedBy ?? this.requestedBy,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      isOnline: isOnline ?? this.isOnline,
      isRead: isRead ?? this.isRead,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'status': status.name,
      'sessionId': sessionId,
      'createdAt': createdAt.toIso8601String(),
      'requestedBy': requestedBy,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessage': lastMessage,
      'isOnline': isOnline,
      'isRead': isRead,
      'unreadCount': unreadCount,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'],
      status: FriendStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FriendStatus.temporary,
      ),
      sessionId: map['sessionId'],
      createdAt: DateTime.parse(map['createdAt']),
      requestedBy: map['requestedBy'],
      lastMessageTime:
          map['lastMessageTime'] != null
              ? DateTime.parse(map['lastMessageTime'])
              : null,
      lastMessage: map['lastMessage'],
      isOnline: map['isOnline'] ?? false,
      isRead: map['isRead'] ?? true,
      unreadCount: map['unreadCount'] ?? 0,
    );
  }
}
