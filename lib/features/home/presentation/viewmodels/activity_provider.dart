import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/features/home/domain/entities/activity.dart';
import 'package:frontend/services/activities_service.dart';

// Activities service provider
final activitiesServiceProvider = Provider((ref) => ActivitiesService());

// Selected category filter
final selectedActivityCategoryProvider = StateProvider<ActivityCategory?>((ref) => null);

// Search query
final activitySearchQueryProvider = StateProvider<String>((ref) => '');

// Sort option
enum ActivitySortOption { rating, priceAsc, priceDesc, duration }
final activitySortOptionProvider = StateProvider<ActivitySortOption>((ref) => ActivitySortOption.rating);

// Price range filter
final activityPriceRangeProvider = StateProvider<(double, double)>((ref) => (0, 500));

// Activities state
class ActivitiesState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;
  final String? cityName;
  final String? countryName;

  ActivitiesState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
    this.cityName,
    this.countryName,
  });

  ActivitiesState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
    String? cityName,
    String? countryName,
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
    );
  }
}

// Activities notifier
class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  final ActivitiesService _service;

  ActivitiesNotifier(this._service) : super(ActivitiesState());

  Future<void> loadActivities({
    required String cityName,
    required String countryName,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      cityName: cityName,
      countryName: countryName,
    );

    try {
      // Always use searchActivitiesByCity which handles geocoding internally
      final activities = await _service.searchActivitiesByCity(
        cityName: cityName,
        countryName: countryName,
      );

      state = state.copyWith(
        activities: activities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void toggleFavorite(String activityId) {
    final updatedActivities = state.activities.map((activity) {
      if (activity.id == activityId) {
        return activity.copyWith(isFavorite: !activity.isFavorite);
      }
      return activity;
    }).toList();
    
    state = state.copyWith(activities: updatedActivities);
  }

  void addComment(String activityId, ActivityComment comment) {
    final updatedActivities = state.activities.map((activity) {
      if (activity.id == activityId) {
        return activity.copyWith(
          comments: [...activity.comments, comment],
        );
      }
      return activity;
    }).toList();
    
    state = state.copyWith(activities: updatedActivities);
  }

  Activity? getActivityById(String id) {
    try {
      return state.activities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Main activities provider
final activitiesProvider = StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
  final service = ref.watch(activitiesServiceProvider);
  return ActivitiesNotifier(service);
});

// Filtered activities provider
final filteredActivitiesProvider = Provider<List<Activity>>((ref) {
  final state = ref.watch(activitiesProvider);
  final selectedCategory = ref.watch(selectedActivityCategoryProvider);
  final searchQuery = ref.watch(activitySearchQueryProvider);
  final sortOption = ref.watch(activitySortOptionProvider);
  final priceRange = ref.watch(activityPriceRangeProvider);

  var activities = state.activities;

  // Filter by category
  if (selectedCategory != null) {
    activities = activities.where((a) => a.category == selectedCategory).toList();
  }

  // Filter by search query
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    activities = activities.where((a) =>
        a.name.toLowerCase().contains(query) ||
        a.description.toLowerCase().contains(query) ||
        a.category.displayName.toLowerCase().contains(query)
    ).toList();
  }

  // Filter by price range
  activities = activities.where((a) =>
      a.price >= priceRange.$1 && a.price <= priceRange.$2
  ).toList();

  // Sort
  switch (sortOption) {
    case ActivitySortOption.rating:
      activities.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case ActivitySortOption.priceAsc:
      activities.sort((a, b) => a.price.compareTo(b.price));
      break;
    case ActivitySortOption.priceDesc:
      activities.sort((a, b) => b.price.compareTo(a.price));
      break;
    case ActivitySortOption.duration:
      activities.sort((a, b) => a.duration.compareTo(b.duration));
      break;
  }

  return activities;
});

// Favorite activities provider
final favoriteActivitiesProvider = Provider<List<Activity>>((ref) {
  final state = ref.watch(activitiesProvider);
  return state.activities.where((a) => a.isFavorite).toList();
});

// Activity bookings state
class ActivityBookingsNotifier extends StateNotifier<List<ActivityBooking>> {
  final ActivitiesService _service;

  ActivityBookingsNotifier(this._service) : super([]);

  Future<ActivityBooking?> bookActivity({
    required String activityId,
    required String userId,
    required DateTime activityDate,
    required int numberOfParticipants,
    required double totalPrice,
    String? specialRequests,
  }) async {
    final booking = await _service.bookActivity(
      activityId: activityId,
      userId: userId,
      activityDate: activityDate,
      numberOfParticipants: numberOfParticipants,
      totalPrice: totalPrice,
      specialRequests: specialRequests,
    );

    if (booking != null) {
      state = [...state, booking];
    }
    return booking;
  }

  void cancelBooking(String bookingId) {
    state = state.where((b) => b.id != bookingId).toList();
  }
}

final activityBookingsProvider = StateNotifierProvider<ActivityBookingsNotifier, List<ActivityBooking>>((ref) {
  final service = ref.watch(activitiesServiceProvider);
  return ActivityBookingsNotifier(service);
});
