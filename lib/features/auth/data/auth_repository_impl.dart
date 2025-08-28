import 'package:chat_drop/features/auth/data/auth_remote_datasource.dart';
import 'package:chat_drop/features/auth/domain/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<UserCredential> signInAnonymously() async {
    return await _remoteDatasource.signInAnonymously();
  }

  @override
  Future<String> createSession() async {
    return await _remoteDatasource.createSession();
  }

  @override
  Future<void> joinSession(String sessionId) async {
    await _remoteDatasource.joinSession(sessionId);
  }

  @override
  Future<void> registerUserName(String name) async {
    await _remoteDatasource.registerUserName(name);
  }

  @override
  Future<void> updateUserName(String name) async {
    await _remoteDatasource.updateUserName(name);
  }

  @override
  Future<String?> getCurrentUserName() async {
    return await _remoteDatasource.getCurrentUserName();
  }
}
