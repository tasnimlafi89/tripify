class Airport {
  final String code;
  final String name;
  final String city;
  final String country;
  final double lat;
  final double lng;

  const Airport({
    required this.code,
    required this.name,
    required this.city,
    required this.country,
    required this.lat,
    required this.lng,
  });

  String get displayName => '$city ($code) - $name';
}

class Airline {
  final String name;
  final String logoUrl; // We can use a placeholder or icon

  const Airline({required this.name, required this.logoUrl});
}

class Flight {
  final String id;
  final Airline airline;
  final String flightNumber;
  final Airport origin;
  final Airport destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double priceUsd;
  final List<String> stops; // List of airport codes or city names
  final int availableSeats;

  const Flight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.priceUsd,
    this.stops = const [],
    required this.availableSeats,
  });

  Duration get duration => arrivalTime.difference(departureTime);
  double get priceTnd => priceUsd * 3.1; // Approximate conversion
}
