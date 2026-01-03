import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../services/api_service.dart';
import '../../domain/entities/trip.dart';

class TripRepository {
  // Change this based on your environment:
  // Android Emulator: 10.0.2.2:8080
  // iOS Simulator: localhost:8080
  // Physical device: your computer's IP address (e.g., 192.168.1.100:8080)
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  final ApiService _apiService = ApiService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final userId = await _apiService.getUserId();
    return {
      'Content-Type': 'application/json',
      if (userId != null) 'X-User-Id': userId,
    };
  }

  // Get all trips for current user
  Future<List<Trip>> getTrips() async {
    try {
      debugPrint('GET $baseUrl/trips');
      final response = await http.get(
        Uri.parse('$baseUrl/trips'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      debugPrint('GET trips response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('Parsed ${data.length} trips from response');
        return data.map((json) => _tripFromJson(json)).toList();
      } else {
        debugPrint('Failed to load trips: ${response.statusCode} - ${response.body}');
        return [];
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      return [];
    } catch (e) {
      debugPrint('Error loading trips: $e');
      return [];
    }
  }

  // Create a new trip
  Future<Trip?> createTrip(Trip trip) async {
    try {
      final tripJson = _tripToJson(trip);
      debugPrint('Creating trip with data: $tripJson');
      debugPrint('POST to: $baseUrl/trips');
      
      final response = await http.post(
        Uri.parse('$baseUrl/trips'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(tripJson),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Trip created successfully: ${data['id']}');
        return _tripFromJson(data);
      } else {
        debugPrint('Failed to create trip: ${response.statusCode} - ${response.body}');
        return null;
      }
    } on SocketException catch (e) {
      debugPrint('No internet connection: $e');
      return null;
    } catch (e) {
      debugPrint('Error creating trip: $e');
      return null;
    }
  }

  // Update a trip
  Future<Trip?> updateTrip(Trip trip) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trips/${trip.id}'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(_tripToJson(trip)),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Trip updated successfully: ${data['id']}');
        return _tripFromJson(data);
      } else {
        debugPrint('Failed to update trip: ${response.statusCode}');
        return null;
      }
    } on SocketException {
      debugPrint('No internet connection');
      return null;
    } catch (e) {
      debugPrint('Error updating trip: $e');
      return null;
    }
  }

  // Delete a trip
  Future<bool> deleteTrip(String tripId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/trips/$tripId'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 204 || response.statusCode == 200) {
        debugPrint('Trip deleted successfully: $tripId');
        return true;
      } else {
        debugPrint('Failed to delete trip: ${response.statusCode}');
        return false;
      }
    } on SocketException {
      debugPrint('No internet connection');
      return false;
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      return false;
    }
  }

  // Toggle favorite
  Future<Trip?> toggleFavorite(String tripId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/trips/$tripId/favorite'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _tripFromJson(data);
      } else {
        debugPrint('Failed to toggle favorite: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return null;
    }
  }

  // Update task status
  Future<Trip?> updateTaskStatus(String tripId, String taskName, bool completed) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/trips/$tripId/tasks/$taskName?completed=$completed'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _tripFromJson(data);
      } else {
        debugPrint('Failed to update task: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      return null;
    }
  }

  // Convert Trip to JSON for API
  Map<String, dynamic> _tripToJson(Trip trip) {
    return {
      'userId': trip.userId,
      'destination': trip.destination,
      'cityName': trip.cityName,
      'countryName': trip.countryName,
      'date': trip.date,
      'days': trip.days,
      'color': '#${trip.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'icon': _iconToString(trip.icon),
      'status': trip.isPast ? 'finished' : 'planning',
      'isFavorite': trip.isFavorite,
      'taskStatus': trip.taskStatus,
      if (trip.latitude != null) 'latitude': trip.latitude,
      if (trip.longitude != null) 'longitude': trip.longitude,
    };
  }

  // Convert JSON to Trip
  Trip _tripFromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      destination: json['destination'] ?? '',
      date: json['date'] ?? 'Planned',
      days: json['days'] ?? 'TBD',
      color: _parseColor(json['color']),
      icon: _parseIcon(json['icon']),
      isPast: json['status'] == 'finished',
      isFavorite: json['isFavorite'] == true || json['favorite'] == true,
      cityName: json['cityName'],
      countryName: json['countryName'],
      taskStatus: _parseTaskStatus(json['taskStatus']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.purple;
    try {
      final hex = colorStr.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.purple;
    }
  }

  IconData _parseIcon(String? iconStr) {
    switch (iconStr) {
      case 'flight':
      case 'flight_takeoff_rounded':
        return Icons.flight_takeoff_rounded;
      case 'public':
      case 'public_rounded':
        return Icons.public_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'beach':
        return Icons.beach_access_rounded;
      default:
        return Icons.flight_takeoff_rounded;
    }
  }

  String _iconToString(IconData icon) {
    if (icon == Icons.flight_takeoff_rounded || icon == Icons.flight) return 'flight';
    if (icon == Icons.public_rounded || icon == Icons.public) return 'public';
    if (icon == Icons.hotel_rounded || icon == Icons.hotel) return 'hotel';
    if (icon == Icons.beach_access_rounded) return 'beach';
    return 'flight';
  }

  Map<String, bool> _parseTaskStatus(dynamic taskStatus) {
    if (taskStatus == null) {
      return {
        'Transportation': false,
        'Hotels': false,
        'Activities': false,
        'Budget': false,
      };
    }
    if (taskStatus is Map) {
      return Map<String, bool>.from(taskStatus.map((k, v) => MapEntry(k.toString(), v == true)));
    }
    return {
      'Transportation': false,
      'Hotels': false,
      'Activities': false,
      'Budget': false,
    };
  }
}
