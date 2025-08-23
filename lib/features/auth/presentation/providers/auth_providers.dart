import 'package:chat_drop/features/auth/data/auth_remote_datasource.dart';
import 'package:chat_drop/features/auth/data/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the data source
final authRemoteDataSourceProvider = Provider((ref) => AuthRemoteDatasource());

// Provider for the repository
final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDataSourceProvider),
  ),
);


// Provider to get the current session ID
final sessionIdProvider = StateProvider<String?>((ref) => null);

// Provider to handle creating a session
final createSessionProvider = FutureProvider((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  await authRepository.signInAnonymously();
  final sessionId = await authRepository.createSession();
  ref.read(sessionIdProvider.notifier).state = sessionId;
  return sessionId;
});