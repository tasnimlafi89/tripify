import '../../domain/entities/User.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<UserEntity?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<UserEntity?> get currentUser => _remoteDataSource.currentUser;

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmail(email, password);
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signUpWithEmail(name, email, password);
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() {
    return _remoteDataSource.deleteAccount();
  }
}
