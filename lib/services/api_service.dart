import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL backend
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _userId;

  // ==================== USERID STORAGE ====================
  String? get cachedUserId => _userId;

  Future<void> setUserId(String? userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString('userId', userId);
    } else {
      await prefs.remove('userId');
    }
  }

  Future<String?> getUserId() async {
    if (_userId != null) return _userId;
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    return _userId;
  }

  Future<void> clearUserId() async {
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // ==================== HEADERS ====================
  Map<String, String> _getPublicHeaders() => {'Content-Type': 'application/json'};

  Future<Map<String, String>> _getAuthHeaders() async {
    final userId = await getUserId();
    if (userId == null) throw ApiException('User not authenticated', 401);
    return {
      'Content-Type': 'application/json',
      'X-User-Id': userId,
    };
  }

  // ==================== GENERIC REQUESTS ====================
  Future<dynamic> _handleResponse(http.Response response) async {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final message = body is Map ? body['message'] ?? 'Unknown error' : 'Request failed';
    throw ApiException(message, response.statusCode);
  }

  Future<dynamic> _postPublic(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getPublicHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    }
  }

  Future<dynamic> _post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getAuthHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    }
  }

  Future<dynamic> _get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 30));
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    }
  }

  Future<dynamic> _put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getAuthHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    }
  }

  Future<dynamic> _delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 30));
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    }
  }

  // ==================== AUTH ====================
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _postPublic('/users/register', body: {
      'email': email,
      'password': password,
      'displayName': name,
    });
    if (response != null && response['id'] != null) await setUserId(response['id']);
    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _postPublic('/users/login', body: {
      'email': email,
      'password': password,
    });
    if (response != null && response['id'] != null) await setUserId(response['id']);
    return response;
  }

  Future<void> logout() async => await clearUserId();

  // ==================== USER PROFILE ====================
  Future<Map<String, dynamic>> getUserProfile() async => await _get('/users/me');

  Future<Map<String, dynamic>> updateUserProfile({String? displayName, String? photoUrl}) async =>
      await _put('/users/me', body: {
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

  Future<void> deleteAccount() async {
    await _delete('/users/me');
    await clearUserId();
  }

  // ==================== TRIPS & DESTINATIONS ====================
  Future<List<dynamic>> getTrips() async => await _get('/trips') as List<dynamic>;

  Future<Map<String, dynamic>> getTrip(String tripId) async => await _get('/trips/$tripId');

  Future<Map<String, dynamic>> createTrip({
    required String destination,
    required String date,
    required String days,
    String? cityName,
    String? countryName,
    String? status,
    String? color,
    String? icon,
    bool? isFavorite,
    bool? booked,
    double? latitude,
    double? longitude,
    Map<String, bool>? taskStatus,
  }) async {
    return await _post('/trips', body: {
      'destination': destination,
      'date': date,
      'days': days,
      if (cityName != null) 'cityName': cityName,
      if (countryName != null) 'countryName': countryName,
      if (status != null) 'status': status,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (booked != null) 'booked': booked,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (taskStatus != null) 'taskStatus': taskStatus,
    });
  }

  Future<List<dynamic>> getPopularDestinations() async => await _get('/destinations/popular') as List<dynamic>;

  Future<List<dynamic>> searchDestinations(String query) async =>
      await _get('/destinations/search?q=$query') as List<dynamic>;

  Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required int days,
    List<String>? interests,
    double? budget,
    String? travelStyle,
  }) async {
    return await _post('/ai/generate-itinerary', body: {
      'destination': destination,
      'days': days,
      if (interests != null) 'interests': interests,
      if (budget != null) 'budget': budget,
      if (travelStyle != null) 'travelStyle': travelStyle,
    });
  }
}

// ==================== EXCEPTION ====================
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}
