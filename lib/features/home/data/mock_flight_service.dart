import 'dart:math';
import '../domain/entities/flight.dart';

class MockFlightService {
  // Hardcoded popular airports
  static const List<Airport> airports = [
    Airport(code: 'TUN', name: 'Carthage', city: 'Tunis', country: 'Tunisia', lat: 36.8510, lng: 10.2272),
    Airport(code: 'JFK', name: 'John F. Kennedy', city: 'New York', country: 'USA', lat: 40.6413, lng: -73.7781),
    Airport(code: 'LHR', name: 'Heathrow', city: 'London', country: 'UK', lat: 51.4700, lng: -0.4543),
    Airport(code: 'CDG', name: 'Charles de Gaulle', city: 'Paris', country: 'France', lat: 49.0097, lng: 2.5479),
    Airport(code: 'DXB', name: 'International', city: 'Dubai', country: 'UAE', lat: 25.2532, lng: 55.3657),
    Airport(code: 'HND', name: 'Haneda', city: 'Tokyo', country: 'Japan', lat: 35.5494, lng: 139.7798),
    Airport(code: 'SIN', name: 'Changi', city: 'Singapore', country: 'Singapore', lat: 1.3644, lng: 103.9915),
    Airport(code: 'SYD', name: 'Kingsford Smith', city: 'Sydney', country: 'Australia', lat: -33.9399, lng: 151.1753),
    Airport(code: 'IST', name: 'Istanbul', city: 'Istanbul', country: 'Turkey', lat: 41.2753, lng: 28.7519),
    Airport(code: 'FRA', name: 'Frankfurt', city: 'Frankfurt', country: 'Germany', lat: 50.0379, lng: 8.5622),
  ];

  static const List<Airline> airlines = [
    Airline(name: 'Tunisair', logoUrl: 'assets/airlines/tunisair.png'),
    Airline(name: 'Emirates', logoUrl: 'assets/airlines/emirates.png'),
    Airline(name: 'Air France', logoUrl: 'assets/airlines/airfrance.png'),
    Airline(name: 'Lufthansa', logoUrl: 'assets/airlines/lufthansa.png'),
    Airline(name: 'Delta', logoUrl: 'assets/airlines/delta.png'),
  ];

  Future<List<Airport>> searchAirports(String query) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate net lag
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return airports.where((a) => 
      a.code.toLowerCase().contains(q) || 
      a.city.toLowerCase().contains(q) || 
      a.country.toLowerCase().contains(q)
    ).toList();
  }

  Future<Map<String, dynamic>> searchFlights(Airport origin, Airport destination, DateTime date) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate search

    double distance = _calculateDistance(origin.lat, origin.lng, destination.lat, destination.lng);

    // Logic: Too close or too far check
    if (distance < 100) {
      return {
        'success': false,
        'message': 'Distance is too short for a flight (< 100km). Consider taking a train or car.',
        'flights': <Flight>[],
      };
    }
    
    // Generate mock flights
    final random = Random();
    final List<Flight> flights = [];
    int flightCount = random.nextInt(5) + 3; // 3 to 7 flights

    for (int i = 0; i < flightCount; i++) {
      final airline = airlines[random.nextInt(airlines.length)];
      final isDirect = distance < 3000 || random.nextBool();
      final stops = isDirect ? <String>[] : [_getRandomHub(origin, destination)];
      
      // Calculate realistic price based on distance
      double basePrice = distance * 0.1; // $0.10 per km approx
      double priceVariation = random.nextDouble() * 0.4 + 0.8; // 0.8 to 1.2
      double price = basePrice * priceVariation;
      if (!isDirect) price *= 0.8; // Cheaper if layover

      // Times
      final depHour = 6 + random.nextInt(16); // 06:00 to 22:00
      final departure = DateTime(date.year, date.month, date.day, depHour, random.nextInt(60));
      double flightHours = (distance / 800) + (isDirect ? 0.5 : 3.0); // 800km/h + taxi/layover
      final arrival = departure.add(Duration(minutes: (flightHours * 60).round()));

      flights.add(Flight(
        id: 'FL-${random.nextInt(9999)}',
        airline: airline,
        flightNumber: '${airline.name.substring(0, 2).toUpperCase()}${random.nextInt(900) + 100}',
        origin: origin,
        destination: destination,
        departureTime: departure,
        arrivalTime: arrival,
        priceUsd: price,
        stops: stops,
        availableSeats: random.nextInt(50) + 5,
      ));
    }

    // Sort by price
    flights.sort((a, b) => a.priceUsd.compareTo(b.priceUsd));

    return {
      'success': true,
      'message': 'Found ${flights.length} flights',
      'flights': flights,
      'distance': distance,
    };
  }

  String _getRandomHub(Airport origin, Airport destination) {
    // Pick a random airport that isn't origin or dest
    final hubs = airports.where((a) => a != origin && a != destination).toList();
    if (hubs.isEmpty) return "Hub";
    return hubs[Random().nextInt(hubs.length)].city;
  }

  static Airport? findClosestAirport(double lat, double lng) {
    if (airports.isEmpty) return null;
    
    Airport? closest;
    double minDistance = double.infinity;
    
    for (final airport in airports) {
      final dist = _calculateDistance(lat, lng, airport.lat, airport.lng);
      if (dist < minDistance) {
        minDistance = dist;
        closest = airport;
      }
    }
    return closest;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}
