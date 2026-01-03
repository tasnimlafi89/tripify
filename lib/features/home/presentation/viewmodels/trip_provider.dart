import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../services/api_service.dart';
import '../../data/repositories/trip_repository.dart';
import '../../domain/entities/trip.dart';

/// Repository provider
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository();
});

/// Trip state notifier that persists to database
class TripNotifier extends StateNotifier<List<Trip>> {
  final TripRepository _repository;
  bool _isLoading = false;
  bool _isInitialized = false;

  TripNotifier(this._repository) : super([]);

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Load trips from database
  Future<void> loadTrips({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_isInitialized && !forceRefresh) return;
    
    _isLoading = true;
    try {
      debugPrint('Loading trips from database...');
      final trips = await _repository.getTrips();
      state = trips;
      _isInitialized = true;
      debugPrint('Loaded ${trips.length} trips from database');
    } catch (e) {
      debugPrint('Error loading trips: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  /// Force refresh trips from database
  Future<void> refreshTrips() async {
    _isInitialized = false;
    await loadTrips(forceRefresh: true);
  }

  /// Add a new trip and save to database
  Future<Trip?> addTrip(Trip trip) async {
    try {
      final savedTrip = await _repository.createTrip(trip);
      if (savedTrip != null) {
        state = [...state, savedTrip];
        debugPrint('Trip added and saved: ${savedTrip.id}');
        return savedTrip;
      } else {
        // Fallback: add to local state even if API fails
        state = [...state, trip];
        debugPrint('Trip added locally (API failed)');
        return trip;
      }
    } catch (e) {
      debugPrint('Error adding trip: $e');
      // Fallback: add to local state
      state = [...state, trip];
      return trip;
    }
  }

  /// Update a trip and save to database
  Future<Trip?> updateTrip(Trip updatedTrip) async {
    try {
      final savedTrip = await _repository.updateTrip(updatedTrip);
      if (savedTrip != null) {
        state = [
          for (final trip in state)
            if (trip.id == savedTrip.id) savedTrip else trip
        ];
        debugPrint('Trip updated and saved: ${savedTrip.id}');
        return savedTrip;
      } else {
        // Fallback: update local state even if API fails
        state = [
          for (final trip in state)
            if (trip.id == updatedTrip.id) updatedTrip else trip
        ];
        return updatedTrip;
      }
    } catch (e) {
      debugPrint('Error updating trip: $e');
      state = [
        for (final trip in state)
          if (trip.id == updatedTrip.id) updatedTrip else trip
      ];
      return updatedTrip;
    }
  }

  /// Remove a trip and delete from database
  Future<bool> removeTrip(String tripId) async {
    try {
      final success = await _repository.deleteTrip(tripId);
      if (success) {
        state = state.where((t) => t.id != tripId).toList();
        debugPrint('Trip removed: $tripId');
        return true;
      } else {
        // Fallback: remove from local state
        state = state.where((t) => t.id != tripId).toList();
        return true;
      }
    } catch (e) {
      debugPrint('Error removing trip: $e');
      state = state.where((t) => t.id != tripId).toList();
      return true;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String tripId) async {
    try {
      final updatedTrip = await _repository.toggleFavorite(tripId);
      if (updatedTrip != null) {
        state = [
          for (final trip in state)
            if (trip.id == tripId) updatedTrip else trip
        ];
      } else {
        // Fallback: toggle locally
        state = [
          for (final trip in state)
            if (trip.id == tripId)
              trip.copyWith(isFavorite: !trip.isFavorite)
            else
              trip
        ];
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      state = [
        for (final trip in state)
          if (trip.id == tripId)
            trip.copyWith(isFavorite: !trip.isFavorite)
          else
            trip
      ];
    }
  }

  /// Update task status
  Future<void> updateTaskStatus(String tripId, String taskName, bool completed) async {
    try {
      final updatedTrip = await _repository.updateTaskStatus(tripId, taskName, completed);
      if (updatedTrip != null) {
        state = [
          for (final trip in state)
            if (trip.id == tripId) updatedTrip else trip
        ];
      } else {
        // Fallback: update locally
        state = [
          for (final trip in state)
            if (trip.id == tripId)
              trip.copyWith(
                taskStatus: {...trip.taskStatus, taskName: completed},
              )
            else
              trip
        ];
      }
    } catch (e) {
      debugPrint('Error updating task status: $e');
    }
  }

  /// Mark trip as completed
  void markAsCompleted(String tripId) {
    state = [
      for (final trip in state)
        if (trip.id == tripId)
          trip.copyWith(isPast: true)
        else
          trip
    ];
  }

  /// Clear all trips (called on sign out)
  void clearTrips() {
    state = [];
    _isInitialized = false;
    debugPrint('Trips cleared');
  }
}

// Current user provider - uses cached userId from ApiService
// Returns empty string if not logged in (for fallback/dev purposes)
final currentUserProvider = Provider<String>((ref) {
  return ApiService().cachedUserId ?? '';
});

/// Main trip provider
final tripProvider = StateNotifierProvider<TripNotifier, List<Trip>>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripNotifier(repository);
});

/// Loading state provider
final tripLoadingProvider = Provider<bool>((ref) {
  final notifier = ref.watch(tripProvider.notifier);
  return notifier.isLoading;
});

/// Filtered trips provider for different views
final filteredTripsProvider = Provider.family<List<Trip>, String>((ref, filter) {
  final trips = ref.watch(tripProvider);

  switch (filter) {
    case 'Planning':
      return trips.where((t) => !t.isPast && !t.isFullyPlanned).toList();
    case 'Finished':
      return trips.where((t) => t.isPast || t.isFullyPlanned).toList();
    case 'Favorites':
      return trips.where((t) => t.isFavorite).toList();
    default:
      return trips;
  }
});
