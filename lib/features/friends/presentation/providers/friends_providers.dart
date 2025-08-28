import 'package:chat_drop/features/chat/domain/message.dart';
import 'package:chat_drop/features/chat/presentation/providers/chat_providers.dart';
import 'package:chat_drop/features/friends/data/friends_remote_datasource.dart';
import 'package:chat_drop/features/friends/data/friends_repository_impl.dart';
import 'package:chat_drop/features/friends/domain/friends_repository.dart';
import 'package:chat_drop/features/friends/domain/models/friend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

// Repository provider
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepositoryImpl(FriendsRemoteDataSource());
});

// Friends list provider
final friendsProvider = StreamProvider<List<Friend>>((ref) {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getFriends();
});

final friendNameCacheProvider = StateProvider<Map<String, String>>((ref) => {});

// Alternative name that matches widget
final friendsStreamProvider = StreamProvider<List<Friend>>((ref) {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getFriends();
});

// // Move this provider to the top level (outside of FriendActions class)
// final friendsWithMessagesProvider = StreamProvider<List<Friend>>((ref) async* {
//   final friendsStream = ref.watch(friendsStreamProvider.stream);

//   await for (final friends in friendsStream) {
//     final friendsWithMessages = <Friend>[];

//     for (final friend in friends) {
//       if (friend.sessionId != null) {
//         try {
//           // Get the last message for this friend's session
//           final chatRepository = ref.read(chatRepositoryProvider);
//           final messagesStream = chatRepository.getMessages(friend.sessionId!);

//           // Get the latest messages (just take the first emission)
//           final messages = await messagesStream.first;

//           String lastMessage = 'No messages yet';
//           if (messages.isNotEmpty) {
//             // Get the most recent message
//             final sortedMessages =
//                 messages.toList()
//                   ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
//             lastMessage = sortedMessages.first.content;
//           }

//           // Create a new friend object with the last message
//           friendsWithMessages.add(
//             Friend(
//               id: friend.id,
//               name: friend.name,
//               avatar: friend.avatar,
//               status: friend.status,
//               sessionId: friend.sessionId,
//               createdAt: friend.createdAt,
//               isOnline: friend.isOnline,
//               isRead: friend.isRead,
//               unreadCount: friend.unreadCount,
//               lastMessage: lastMessage,
//               lastMessageTime:
//                   messages.isNotEmpty
//                       ? messages.last.timestamp
//                       : friend.lastMessageTime,
//             ),
//           );
//         } catch (e) {
//           print('Error getting last message for friend ${friend.name}: $e');
//           // If there's an error, just add the friend without updating the message
//           friendsWithMessages.add(friend);
//         }
//       } else {
//         // If no session ID, just add the friend as-is
//         friendsWithMessages.add(friend);
//       }
//     }

//     yield friendsWithMessages;
//   }
// });

// // Real-time message count and online status
// final friendsWithRealTimeDataProvider = StreamProvider<List<Friend>>((ref) {
//   final friendsStream = ref.watch(friendsStreamProvider);
//   final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//   if (currentUserId == null) {
//     return Stream.value([]);
//   }

//   return friendsStream.when(
//     data: (friends) {
//       if (friends.isEmpty) {
//         return Stream.value([]);
//       }

//       // Create a list of streams for each friend's messages
//       final friendStreams =
//           friends.map((friend) {
//             if (friend.sessionId == null) {
//               return Stream.value(friend);
//             }

//             // Listen to real-time messages for this friend's session
//             final chatRepository = ref.read(chatRepositoryProvider);
//             return chatRepository.getMessages(friend.sessionId!).map((
//               messages,
//             ) {
//               int unreadCount = 0;
//               String lastMessage = 'No messages yet';
//               DateTime? lastMessageTime;

//               if (messages.isNotEmpty) {
//                 // Sort messages by timestamp (newest first for last message)
//                 final sortedMessages =
//                     messages.toList()
//                       ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

//                 // Get the latest message
//                 lastMessage = sortedMessages.first.content;
//                 lastMessageTime = sortedMessages.first.timestamp;

//                 // Count unread messages from other users
//                 unreadCount =
//                     messages
//                         .where(
//                           (msg) => msg.senderId != currentUserId && !msg.isRead,
//                         )
//                         .length;

//                 print('Real-time update for ${friend.name}:');
//                 print('  Total messages: ${messages.length}');
//                 print('  Last message: $lastMessage');
//                 print('  Unread count: $unreadCount');
//               }

//               // Return updated friend with real-time data
//               return Friend(
//                 id: friend.id,
//                 name: friend.name,
//                 avatar: friend.avatar,
//                 status: friend.status,
//                 sessionId: friend.sessionId,
//                 createdAt: friend.createdAt,
//                 isOnline: true,
//                 isRead: unreadCount == 0,
//                 unreadCount: unreadCount,
//                 lastMessage: lastMessage,
//                 lastMessageTime: lastMessageTime,
//               );
//             });
//           }).toList();

//       // Combine all friend streams into one
//       return Stream.value(friendStreams)
//           .asyncExpand((streams) {
//             return Stream.value(streams);
//           })
//           .asyncMap((streamList) async {
//             final List<Friend> result = [];

//             for (final friendStream in streamList) {
//               try {
//                 final friend = await friendStream.first;
//                 result.add(friend);
//               } catch (e) {
//                 print('Error getting friend data: $e');
//               }
//             }

//             return result;
//           });
//     },
//     loading: () => Stream.value([]),
//     error: (error, stack) {
//       print('Error in friends stream: $error');
//       return Stream.value([]);
//     },
//   );
// });

// Add this new provider that properly combines real-time streams
final friendsWithLiveMessagesProvider = StreamProvider<List<Friend>>((ref) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) {
    return Stream.value([]);
  }

  // Get the base friends stream
  final friendsAsync = ref.watch(friendsStreamProvider);

  return friendsAsync.when(
    data: (friends) {
      if (friends.isEmpty) {
        return Stream.value([]);
      }

      // Create a stream for each friend with their messages
      final chatRepository = ref.read(chatRepositoryProvider);

      final friendWithMessageStreams =
          friends.map((friend) {
            if (friend.sessionId == null) {
              return Stream.value(friend);
            }

            // Get real-time messages for this friend
            return chatRepository
                .getMessages(friend.sessionId!)
                .map((messages) {
                  int unreadCount = 0;
                  String lastMessage = 'No messages yet';
                  DateTime? lastMessageTime;

                  if (messages.isNotEmpty) {
                    // Sort by timestamp (newest first)
                    final sortedMessages = List<Message>.from(messages)
                      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    lastMessage = sortedMessages.first.content;
                    lastMessageTime = sortedMessages.first.timestamp;

                    // Count unread messages from this friend
                    unreadCount =
                        messages
                            .where(
                              (msg) =>
                                  msg.senderId != currentUserId && !msg.isRead,
                            )
                            .length;

                    print(
                      '🔄 Live update - ${friend.name}: $unreadCount unread, last: "$lastMessage"',
                    );
                  }

                  return Friend(
                    id: friend.id,
                    name: friend.name,
                    avatar: friend.avatar,
                    status: friend.status,
                    sessionId: friend.sessionId,
                    createdAt: friend.createdAt,
                    isOnline: true,
                    isRead: unreadCount == 0,
                    unreadCount: unreadCount,
                    lastMessage: lastMessage,
                    lastMessageTime: lastMessageTime,
                  );
                })
                .handleError((error) {
                  print('Error in message stream for ${friend.name}: $error');
                  return friend; // Return original friend on error
                });
          }).toList();

      // Combine all streams using combineLatest for real-time updates
      if (friendWithMessageStreams.isEmpty) {
        return Stream.value([]);
      }

      return CombineLatestStream.list(friendWithMessageStreams);
    },
    loading: () => Stream.value([]),
    error: (error, stack) {
      print('Error loading friends: $error');
      return Stream.value([]);
    },
  );
});

// Individual friend provider
final friendProvider = StreamProvider.family<Friend?, String>((ref, friendId) {
  final friendsAsync = ref.watch(friendsStreamProvider);

  return friendsAsync
      .when(
        data: (friends) {
          try {
            final friend = friends.firstWhere((f) => f.id == friendId);
            return Stream.value(friend);
          } catch (e) {
            return Stream.value(null);
          }
        },
        loading: () => Stream.value(null),
        error: (error, stack) => Stream.value(null),
      )
      .asBroadcastStream();
});

// Keep the old FutureProvider version for backward compatibility
final friendFutureProvider = FutureProvider.family<Friend?, String>((
  ref,
  friendId,
) {
  final repository = ref.read(friendsRepositoryProvider);
  return repository.getFriend(friendId);
});

// Provider for friend actions
final friendActionsProvider = Provider((ref) => FriendActions(ref));

class FriendActions {
  final Ref _ref;
  FriendActions(this._ref);

  Future<void> sendFriendRequest(String friendId) async {
    try {
      final repository = _ref.read(friendsRepositoryProvider);
      await repository.sendFriendRequest(friendId);
      _ref.invalidate(friendsStreamProvider);
    } catch (e) {
      print('Failed to send friend request: $e');
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String friendId) async {
    try {
      final repository = _ref.read(friendsRepositoryProvider);
      await repository.acceptFriendRequest(friendId);
      _ref.invalidate(friendsStreamProvider);
    } catch (e) {
      print('Failed to accept friend request: $e');
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(String friendId) async {
    try {
      final repository = _ref.read(friendsRepositoryProvider);
      await repository.rejectFriendRequest(friendId);
      _ref.invalidate(friendsStreamProvider);
    } catch (e) {
      print('Failed to reject friend request: $e');
      rethrow;
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      final repository = _ref.read(friendsRepositoryProvider);
      await repository.removeFriend(friendId);
      _ref.invalidate(friendsStreamProvider);
    } catch (e) {
      print('Failed to remove friend: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String friendId) async {
    try {
      final repository =
          _ref.read(friendsRepositoryProvider) as FriendsRepositoryImpl;
      await repository.markAsRead(friendId);

      // Also mark chat messages as read
      final friend = await repository.getFriend(friendId);
      if (friend?.sessionId != null) {
        final chatRepository = _ref.read(chatRepositoryProvider);
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        // Add the missing currentUserId parameter
        if (currentUserId != null) {
          await chatRepository.markAllMessagesAsRead(
            friend!.sessionId!,
            currentUserId,
          );
        }
      }

      _ref.invalidate(friendsWithLiveMessagesProvider);
    } catch (e) {
      print('Failed to mark as read: $e');
    }
  }
}
