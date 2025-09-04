class ChatSession {
  final String id;
  final List<String> users;
  final SessionStatus status;
  final String? requestedBy;
  final DateTime createdAt;
  final Map<String, String>? userNames; // Add user names mapping

  ChatSession({
    required this.id,
    required this.users,
    required this.status,
    this.requestedBy,
    required this.createdAt,
    this.userNames,
  });
}

enum SessionStatus { temporary, pending, permanent }
