import 'package:chat_drop/features/auth/data/auth_remote_datasource.dart';
import 'package:chat_drop/features/auth/domain/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<UserCredential> signInAnonymously() {
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

  @override
  Future<void> registerUserName(String name) {
    return remoteDatasource.registerUserName(name);
  }
}
