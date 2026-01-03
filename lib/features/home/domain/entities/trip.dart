import 'package:flutter/material.dart';

class Trip {
  final String id;
  final String userId;
  final String destination;
  final String date;
  final String days;
  final Color color;
  final IconData icon;
  final bool isPast;
  final bool isFavorite;
  final String? cityName;
  final String? countryName;
  final Map<String, bool> taskStatus;
  final double? latitude;
  final double? longitude;

  Trip({
    required this.id,
    required this.userId,
    required this.destination,
    required this.date,
    required this.days,
    required this.color,
    required this.icon,
    this.isPast = false,
    this.isFavorite = false,
    this.cityName,
    this.countryName,
    this.taskStatus = const {},
    this.latitude,
    this.longitude,
  });

  Trip copyWith({
    String? id,
    String? userId,
    String? destination,
    String? date,
    String? days,
    Color? color,
    IconData? icon,
    bool? isPast,
    bool? isFavorite,
    String? cityName,
    String? countryName,
    Map<String, bool>? taskStatus,
    double? latitude,
    double? longitude,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      days: days ?? this.days,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isPast: isPast ?? this.isPast,
      isFavorite: isFavorite ?? this.isFavorite,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      taskStatus: taskStatus ?? this.taskStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Check if all tasks are completed
  bool get isFullyPlanned {
    if (taskStatus.isEmpty) return false;
    return taskStatus.values.every((v) => v);
  }

  /// Get progress as a percentage (0.0 to 1.0)
  double get progress {
    if (taskStatus.isEmpty) return 0.0;
    final completed = taskStatus.values.where((v) => v).length;
    return completed / taskStatus.length;
  }
}
