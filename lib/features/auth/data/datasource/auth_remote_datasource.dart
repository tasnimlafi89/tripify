import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/api_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> get currentUser;
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String name, String email, String password);
  Future<void> signOut();
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  AuthRemoteDataSourceImpl({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService() {
    _init();
  }

  Future<void> _init() async {
    final userId = await _apiService.getUserId();
    if (userId != null) {
      try {
        final userData = await _apiService.getUserProfile();
        _currentUser = UserModel.fromJson(userData);
        _authStateController.add(_currentUser);
      } catch (e) {
        await _apiService.clearUserId();
        _authStateController.add(null);
      }
    } else {
      _authStateController.add(null);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel?> get currentUser async {
    if (_currentUser != null) return _currentUser;
    
    final userId = await _apiService.getUserId();
    if (userId == null) return null;
    
    try {
      final userData = await _apiService.getUserProfile();
      _currentUser = UserModel.fromJson(userData);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      _currentUser = UserModel.fromJson(response);
      _authStateController.add(_currentUser);
      
      return _currentUser!;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
Future<UserModel> signUpWithEmail(String name, String email, String password) async {
  try {
    final response = await _apiService.register(
      name: name,          // <-- ici, pas displayName
      email: email,
      password: password,
    );

    _currentUser = UserModel.fromJson(response);
    _authStateController.add(_currentUser);

    return _currentUser!;
  } on ApiException catch (e) {
    throw Exception(e.message);
  } catch (e) {
    throw Exception('Failed to sign up: $e');
  }
}


  @override
  Future<void> signOut() async {
    await _apiService.logout();
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _apiService.deleteAccount();
      _currentUser = null;
      _authStateController.add(null);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
