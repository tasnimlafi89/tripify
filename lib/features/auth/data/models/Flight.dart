import 'package:equatable/equatable.dart';

class Flight extends Equatable {
  final String id;
  final String airline;
  final String flightNumber;

  final String departureAirport;
  final String arrivalAirport;

  final DateTime departureTime;
  final DateTime arrivalTime;

  final double price;
  final String currency;

  final String bookingUrl;
  final bool isBooked;

  const Flight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.currency,
    required this.bookingUrl,
    this.isBooked = false,
  });

  /// ---------------------------
  /// JSON → Flight
  /// ---------------------------
  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] as String,
      airline: json['airline'] as String,
      flightNumber: json['flightNumber'] as String,
      departureAirport: json['departureAirport'] as String,
      arrivalAirport: json['arrivalAirport'] as String,
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      bookingUrl: json['bookingUrl'] as String,
      isBooked: json['isBooked'] ?? false,
    );
  }

  /// ---------------------------
  /// Flight → JSON
  /// ---------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'flightNumber': flightNumber,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'price': price,
      'currency': currency,
      'bookingUrl': bookingUrl,
      'isBooked': isBooked,
    };
  }

  /// ---------------------------
  /// CopyWith
  /// ---------------------------
  Flight copyWith({
    bool? isBooked,
  }) {
    return Flight(
      id: id,
      airline: airline,
      flightNumber: flightNumber,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      price: price,
      currency: currency,
      bookingUrl: bookingUrl,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  /// ---------------------------
  /// Helpers (UI)
  /// ---------------------------
  String get route => '$departureAirport → $arrivalAirport';

  Duration get duration => arrivalTime.difference(departureTime);

  @override
  List<Object?> get props => [
        id,
        airline,
        flightNumber,
        departureAirport,
        arrivalAirport,
        departureTime,
        arrivalTime,
        price,
        currency,
        bookingUrl,
        isBooked,
      ];

  get departure => null;

  get arrival => null;
}
