import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/mock_flight_service.dart';
import '../../domain/entities/flight.dart';

final flightServiceProvider = Provider((ref) => MockFlightService());

// State for the search form
final originAirportProvider = StateProvider<Airport?>((ref) => null);
final destinationAirportProvider = StateProvider<Airport?>((ref) => null);
final departureDateProvider = StateProvider<DateTime>((ref) => DateTime.now().add(const Duration(days: 1)));
final passengersProvider = StateProvider<int>((ref) => 1);
final cabinClassProvider = StateProvider<String>((ref) => 'Economy');

// State for search results
class FlightSearchState {
  final bool isLoading;
  final List<Flight> flights;
  final String? error;
  final double? distance;

  FlightSearchState({
    this.isLoading = false,
    this.flights = const [],
    this.error,
    this.distance,
  });
}

class FlightSearchNotifier extends StateNotifier<FlightSearchState> {
  final MockFlightService _service;

  FlightSearchNotifier(this._service) : super(FlightSearchState());

  Future<void> searchFlights(Airport origin, Airport destination, DateTime date) async {
    state = FlightSearchState(isLoading: true);

    try {
      final result = await _service.searchFlights(origin, destination, date);
      
      if (result['success'] == true) {
        state = FlightSearchState(
          flights: result['flights'] as List<Flight>,
          distance: result['distance'] as double?,
        );
      } else {
        state = FlightSearchState(error: result['message'] as String);
      }
    } catch (e) {
      state = FlightSearchState(error: "An unexpected error occurred: $e");
    }
  }

  void setDestination(Airport destAirport) {}

  void setOrigin(Airport originAirport) {}
}

final flightSearchProvider = StateNotifierProvider<FlightSearchNotifier, FlightSearchState>((ref) {
  return FlightSearchNotifier(ref.read(flightServiceProvider));
});
