import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_drop/features/friends/data/friends_remote_datasource.dart';
import 'package:chat_drop/features/friends/data/friends_repository_impl.dart';
import 'package:chat_drop/features/friends/domain/friends_repository.dart';
import 'package:chat_drop/features/friends/domain/models/friend.dart';

// Provider for the remote data source
final friendsRemoteDataSourceProvider = Provider<FriendsRemoteDatasource>(
  (ref) => FriendsRemoteDatasource(),
);

// Provider for the repository
final friendsRepositoryProvider = Provider<FriendsRepository>(
  (ref) => FriendsRepositoryImpl(
    remoteDatasource: ref.watch(friendsRemoteDataSourceProvider),
  ),
);

// Provider to get friends stream
final friendsStreamProvider = StreamProvider<List<Friend>>((ref) {
  final repository = ref.watch(friendsRepositoryProvider);
  return repository.getFriendsStream();
});

// OPTIMIZED: Background initialization with compute
final initializeFriendsProvider = FutureProvider<void>((ref) async {
  final dataSource = ref.watch(friendsRemoteDataSourceProvider);

  // Run initialization in background to avoid blocking UI
  if (kDebugMode) {
    print('🔄 Starting friends initialization in background');
  }

  // Use compute for heavy operations if needed
  await dataSource.initializeSampleFriendsIfNeeded();

  if (kDebugMode) {
    print('✅ Friends initialization completed');
  }
});
