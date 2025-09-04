import 'package:chat_drop/features/chat/domain/chat_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel extends ChatSession {
  SessionModel({
    required super.id,
    required super.users,
    required super.status,
    super.requestedBy,
    required super.createdAt,
    super.userNames,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      users: List<String>.from(data['users'] ?? []),
      status: _statusFromString(data['status']),
      requestedBy: data['requestedBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userNames:
          data['userNames'] != null
              ? Map<String, String>.from(data['userNames'])
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'users': users,
      'status': status.name,
      'requestedBy': requestedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'userNames': userNames,
    };
  }

  static SessionStatus _statusFromString(String? status) {
    switch (status) {
      case 'pending':
        return SessionStatus.pending;
      case 'permanent':
        return SessionStatus.permanent;
      default:
        return SessionStatus.temporary;
    }
  }
}
