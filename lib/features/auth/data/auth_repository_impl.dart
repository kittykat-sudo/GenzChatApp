import 'package:chat_drop/features/auth/data/auth_remote_datasource.dart';
import 'package:chat_drop/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<String> signInAnonymously() {
    return remoteDatasource.signInAnonymously();
  }

  @override
  Future<String> createSession() {
    return remoteDatasource.createSession();
  }

  @override
  Future<void> joinSession(String sessionId) {
    return remoteDatasource.joinSession(sessionId);
  }
}
