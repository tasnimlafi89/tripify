import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'api_service.dart';

// ==================== API SERVICE PROVIDER ====================
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// ==================== USER PROFILE PROVIDER ====================
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getUserProfile();
});

// ==================== TRIPS PROVIDERS ====================
final tripsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getTrips();
});

final tripProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, tripId) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getTrip(tripId);
});

// ==================== DESTINATIONS PROVIDERS ====================
final popularDestinationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getPopularDestinations();
});

final destinationSearchProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  final api = ref.watch(apiServiceProvider);
  return await api.searchDestinations(query);
});

// ==================== AI ITINERARY ====================
class ItineraryState {
  final bool isLoading;
  final Map<String, dynamic>? itinerary;
  final String? error;

  ItineraryState({
    this.isLoading = false,
    this.itinerary,
    this.error,
  });

  ItineraryState copyWith({
    bool? isLoading,
    Map<String, dynamic>? itinerary,
    String? error,
  }) {
    return ItineraryState(
      isLoading: isLoading ?? this.isLoading,
      itinerary: itinerary ?? this.itinerary,
      error: error,
    );
  }
}

class ItineraryNotifier extends StateNotifier<ItineraryState> {
  final ApiService _api;

  ItineraryNotifier(this._api) : super(ItineraryState());

  Future<void> generateItinerary({
    required String destination,
    required int days,
    List<String>? interests,
    double? budget,
    String? travelStyle,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final itinerary = await _api.generateItinerary(
        destination: destination,
        days: days,
        interests: interests,
        budget: budget,
        travelStyle: travelStyle,
      );
      state = state.copyWith(isLoading: false, itinerary: itinerary);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = ItineraryState();
  }
}

final itineraryProvider = StateNotifierProvider<ItineraryNotifier, ItineraryState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ItineraryNotifier(api);
});

// ==================== CREATE TRIP ====================
class CreateTripState {
  final bool isLoading;
  final Map<String, dynamic>? createdTrip;
  final String? error;

  CreateTripState({
    this.isLoading = false,
    this.createdTrip,
    this.error,
  });

  CreateTripState copyWith({
    bool? isLoading,
    Map<String, dynamic>? createdTrip,
    String? error,
  }) {
    return CreateTripState(
      isLoading: isLoading ?? this.isLoading,
      createdTrip: createdTrip ?? this.createdTrip,
      error: error,
    );
  }
}

class CreateTripNotifier extends StateNotifier<CreateTripState> {
  final ApiService _api;
  final Ref _ref;

  CreateTripNotifier(this._api, this._ref) : super(CreateTripState());

  Future<bool> createTrip({
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
    state = state.copyWith(isLoading: true);

    try {
      final trip = await _api.createTrip(
        destination: destination,
        date: date,
        days: days,
        cityName: cityName,
        countryName: countryName,
        status: status,
        color: color,
        icon: icon,
        isFavorite: isFavorite,
        booked: booked,
        latitude: latitude,
        longitude: longitude,
        taskStatus: taskStatus,
      );
      state = state.copyWith(isLoading: false, createdTrip: trip);
      _ref.invalidate(tripsProvider); // Refresh trips list
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = CreateTripState();
  }
}

final createTripProvider = StateNotifierProvider<CreateTripNotifier, CreateTripState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return CreateTripNotifier(api, ref);
});
