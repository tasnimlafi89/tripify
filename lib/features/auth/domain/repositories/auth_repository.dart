import '../entities/User.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  
  Future<UserEntity?> get currentUser;

  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> deleteAccount();
}
