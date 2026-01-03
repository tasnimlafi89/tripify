import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/domain/entities/trip.dart';
import 'package:frontend/features/home/presentation/viewmodels/trip_provider.dart';
import 'package:frontend/features/home/presentation/pages/trip_planning_page.dart';
import 'package:frontend/features/home/presentation/pages/add_trip_page.dart';
import 'dart:math' as math;

// Selected filter provider
final selectedFilterProvider = StateProvider<String>((ref) => 'All');

class HomePageTripsSection extends ConsumerStatefulWidget {
  const HomePageTripsSection({super.key});

  @override
  ConsumerState<HomePageTripsSection> createState() => _HomePageTripsSectionState();
}

class _HomePageTripsSectionState extends ConsumerState<HomePageTripsSection> with TickerProviderStateMixin {
  late AnimationController _filterAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _fabAnimationController;
  
  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    // Load trips from database on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tripProvider.notifier).loadTrips(forceRefresh: true);
    });
  }
  
  @override
  void dispose() {
    _filterAnimationController.dispose();
    _cardAnimationController.dispose();
    _fadeAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }
  
  void _showDeleteDialog(BuildContext context, WidgetRef ref, Trip trip, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: colors.error, size: 28),
            const SizedBox(width: 12),
            Text(
              'Delete Trip?',
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the trip to "${trip.destination}"? This action cannot be undone.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tripProvider.notifier).removeTrip(trip.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip to ${trip.destination} deleted'),
                  backgroundColor: colors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);
    final trips = ref.watch(filteredTripsProvider(selectedFilter));

    final allTrips = ref.watch(tripProvider);
    final upcomingTrip = _getNextUpcomingTrip(allTrips);
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.background.withOpacity(0.3),
                colors.background.withOpacity(0.7),
                colors.background,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimationController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colors.primary.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title "My Trips" Centered
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(-20 * (1 - value), 0),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors.primary,
                                        colors.primaryLight,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'My Trips',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Manage and track your travel adventures',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Filter Tabs with Glassmorphism - Centered
                    Container(
                      height: 70,
                      child: Stack(
                        children: [
                          // Background blur effect
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 400,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.primary.withOpacity(0.05),
                                      colors.primaryLight.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(35),
                                  border: Border.all(
                                    color: colors.primary.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Filter chips - Centered
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                children: [
                                  _buildPremiumFilterChip('All', selectedFilter, colors, ref, 0),
                                  _buildPremiumFilterChip('Planning', selectedFilter, colors, ref, 1),
                                  _buildPremiumFilterChip('Finished', selectedFilter, colors, ref, 2),
                                  _buildPremiumFilterChip('Favorites', selectedFilter, colors, ref, 3, icon: Icons.favorite),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Trip Count with animated number - Centered
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.primary.withOpacity(0.1),
                              colors.primaryLight.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.flight_takeoff_rounded,
                                color: colors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: trips.length),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return Text(
                                  '$value ${value == 1 ? 'Trip' : 'Trips'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Stats Row
                    _buildQuickStats(ref, colors),
                    
                    const SizedBox(height: 32),
                    
                    // Upcoming Trip Highlight
                    if (upcomingTrip != null && selectedFilter == 'All')
                      _buildUpcomingTripHighlight(upcomingTrip, colors, ref),
                    
                    // Trip List - Centered with glassmorphism container
                    Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: trips.isEmpty
                          ? _buildPremiumEmptyState(selectedFilter, colors)
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: trips.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: _buildPremiumTripCard(
                                    trip: trips[index],
                                    colors: colors,
                                    context: context,
                                    ref: ref,
                                    index: index,
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    // Bottom padding for FAB
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
      
      // Floating Action Button
      Positioned(
        bottom: 24,
        right: 24,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticOut,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTripPage()),
                );
              },
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New Trip',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      ],
    );
  }
  
  Trip? _getNextUpcomingTrip(List<Trip> trips) {
    final upcomingTrips = trips.where((t) => !t.isPast && !t.isFullyPlanned).toList();
    if (upcomingTrips.isEmpty) return null;
    return upcomingTrips.first;
  }
  
  Widget _buildUpcomingTripHighlight(Trip trip, AppColors colors, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withOpacity(0.15),
                    colors.primaryLight.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'NEXT UP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          ref.read(tripProvider.notifier).toggleFavorite(trip.id);
                        },
                        child: Icon(
                          trip.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: trip.isFavorite ? Colors.red : colors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: trip.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(trip.icon, color: trip.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.destination,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  trip.date,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  trip.days,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick action button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripPlanningPage(
                              cityName: trip.cityName ?? "No city selected",
                              countryName: trip.countryName ?? trip.destination,
                              tripId: trip.id,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Continue Planning',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumFilterChip(
    String label,
    String selectedFilter,
    AppColors colors,
    WidgetRef ref,
    int index, {
    IconData? icon,
  }) {
    final isSelected = selectedFilter == label;
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _filterAnimationController,
        curve: Interval(index * 0.15, 0.6 + (index * 0.1), curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: _filterAnimationController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state = label;
              _cardAnimationController.reset();
              _cardAnimationController.forward();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          colors.primary,
                          colors.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : colors.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected 
                      ? colors.primary.withOpacity(0.5) 
                      : colors.primary.withOpacity(0.15),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        icon,
                        size: 18,
                        color: isSelected ? Colors.white : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(WidgetRef ref, AppColors colors) {
    final allTrips = ref.watch(tripProvider);
    final plannedCount = allTrips.where((t) => !t.isPast && !t.isFullyPlanned).length;
    final completedCount = allTrips.where((t) => t.isFullyPlanned).length;
    final favoritesCount = allTrips.where((t) => t.isFavorite).length;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatCard(
            icon: Icons.pending_actions_rounded,
            label: 'Planning',
            count: plannedCount,
            color: colors.warning,
            colors: colors,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.check_circle_rounded,
            label: 'Completed',
            count: completedCount,
            color: colors.success,
            colors: colors,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            count: favoritesCount,
            color: Colors.red,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required AppColors colors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumEmptyState(String filter, AppColors colors) {
    String message;
    String subtitle;
    IconData icon;
    
    switch (filter) {
      case 'Planning':
        message = 'No trips in planning';
        subtitle = 'Start a new adventure by creating a trip';
        icon = Icons.edit_calendar_outlined;
        break;
      case 'Finished':
        message = 'No finished trips yet';
        subtitle = 'Complete your first journey';
        icon = Icons.check_circle_outline;
        break;
      case 'Favorites':
        message = 'No favorite trips';
        subtitle = 'Mark your dream destinations as favorites';
        icon = Icons.favorite_border;
        break;
      default:
        message = 'No trips yet';
        subtitle = 'Your journey begins here';
        icon = Icons.flight_takeoff;
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 40),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colors.primary.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon with rotation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Transform.rotate(
                          angle: (1 - value) * math.pi / 4,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.primary.withOpacity(0.1),
                                  colors.primaryLight.withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 48,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddTripPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: colors.primary.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded),
                        const SizedBox(width: 10),
                        const Text(
                          'Create Trip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumTripCard({
    required Trip trip,
    required AppColors colors,
    required BuildContext context,
    required WidgetRef ref,
    required int index,
  }) {
    final completedTasks = trip.taskStatus.values.where((bool v) => v).length;
    final totalTasks = trip.taskStatus.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardAnimationController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOutCubic,
        ),
      )),
      child: FadeTransition(
        opacity: _cardAnimationController,
        child: Dismissible(
          key: Key(trip.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: colors.error, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Trip?',
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Text(
                  'Are you sure you want to delete the trip to "${trip.destination}"?',
                  style: TextStyle(color: colors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: colors.error),
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (direction) {
            ref.read(tripProvider.notifier).removeTrip(trip.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Trip to ${trip.destination} deleted'),
                backgroundColor: colors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () {
                    // Would need to implement undo functionality
                  },
                ),
              ),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.error.withOpacity(0.1),
                  colors.error.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.error.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: colors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: trip.color.withOpacity(0.1),
                  blurRadius: 25,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripPlanningPage(
                        cityName: trip.cityName ?? "No city selected",
                        countryName: trip.countryName ?? trip.destination,
                        tripId: trip.id,
                      ),
                    ),
                  );
                },
                onLongPress: () => _showDeleteDialog(context, ref, trip, colors),
                child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: trip.color.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Animated gradient background
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                trip.color.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Status Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildStatusBadge(trip, progress, colors),
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Icon with gradient background
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        trip.color.withOpacity(0.15),
                                        trip.color.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: trip.color.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    trip.icon,
                                    color: trip.color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              trip.destination,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: colors.textPrimary,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                          // Favorite toggle button
                                          GestureDetector(
                                            onTap: () {
                                              ref.read(tripProvider.notifier).toggleFavorite(trip.id);
                                            },
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0.8, end: 1.0),
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.elasticOut,
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      gradient: trip.isFavorite
                                                          ? LinearGradient(
                                                              colors: [
                                                                Colors.red.withOpacity(0.15),
                                                                Colors.pink.withOpacity(0.15),
                                                              ],
                                                            )
                                                          : null,
                                                      color: trip.isFavorite ? null : colors.surfaceVariant.withOpacity(0.5),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      trip.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                      color: trip.isFavorite ? Colors.red : colors.textHint,
                                                      size: 20,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // City and Country info
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: trip.color.withOpacity(0.8),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              trip.cityName != null 
                                                  ? '${trip.cityName}, ${trip.countryName ?? ''}'
                                                  : trip.countryName ?? trip.destination,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: colors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: colors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            trip.date,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: colors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            trip.days,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Progress section with animated bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      progress == 1.0
                                          ? '✨ Trip completed'
                                          : 'Trip progress',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: progress),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        return Text(
                                          '${(value * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: value == 1.0 ? colors.success : trip.color,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Gradient progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: colors.surfaceVariant.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: progress),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        return Stack(
                                          children: [
                                            FractionallySizedBox(
                                              widthFactor: value,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: value == 1.0
                                                        ? [
                                                            colors.success,
                                                            colors.success.withOpacity(0.7),
                                                          ]
                                                        : [
                                                            trip.color,
                                                            trip.color.withOpacity(0.6),
                                                          ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            // Shimmer effect
                                            if (value < 1.0)
                                              Positioned.fill(
                                                child: FractionallySizedBox(
                                                  widthFactor: value,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.white.withOpacity(0.3),
                                                          Colors.transparent,
                                                        ],
                                                        stops: const [0.0, 0.5, 1.0],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$completedTasks of $totalTasks tasks completed',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textHint,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Subtle shine effect on completed trips
                      if (progress == 1.0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  colors.success.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(Trip trip, double progress, AppColors colors) {
    String label;
    Color bgColor;
    Color textColor;
    IconData icon;
    
    if (progress == 1.0) {
      label = 'Completed';
      bgColor = colors.success.withOpacity(0.15);
      textColor = colors.success;
      icon = Icons.check_circle_rounded;
    } else if (trip.isPast) {
      label = 'Past';
      bgColor = colors.textHint.withOpacity(0.15);
      textColor = colors.textHint;
      icon = Icons.history_rounded;
    } else if (progress > 0) {
      label = 'In Progress';
      bgColor = colors.warning.withOpacity(0.15);
      textColor = colors.warning;
      icon = Icons.pending_rounded;
    } else {
      label = 'Upcoming';
      bgColor = colors.primary.withOpacity(0.15);
      textColor = colors.primary;
      icon = Icons.schedule_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}