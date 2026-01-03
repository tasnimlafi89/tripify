import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/domain/entities/trip.dart';

class FullTripPlanPage extends ConsumerStatefulWidget {
  final Trip trip;
  final List<String> imageUrls;

  const FullTripPlanPage({
    super.key,
    required this.trip,
    required this.imageUrls,
  });

  @override
  ConsumerState<FullTripPlanPage> createState() => _FullTripPlanPageState();
}

class _FullTripPlanPageState extends ConsumerState<FullTripPlanPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late ScrollController _scrollController;
  int _selectedDay = 0;
  double _headerOpacity = 1.0;

  final List<DayItinerary> _itinerary = [];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _generateItinerary();
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _headerOpacity = (1 - (offset / 200)).clamp(0.0, 1.0);
    });
  }

  void _generateItinerary() {
    final random = math.Random(widget.trip.id.hashCode);
    final dayCount = random.nextInt(4) + 3;

    final activities = [
      ItineraryItem(time: '08:00', title: 'Breakfast at Hotel', icon: Icons.restaurant, type: 'meal', duration: '1h'),
      ItineraryItem(time: '09:30', title: 'City Walking Tour', icon: Icons.directions_walk, type: 'activity', duration: '2h 30m'),
      ItineraryItem(time: '12:30', title: 'Lunch at Local Restaurant', icon: Icons.lunch_dining, type: 'meal', duration: '1h 30m'),
      ItineraryItem(time: '14:30', title: 'Museum Visit', icon: Icons.museum, type: 'activity', duration: '2h'),
      ItineraryItem(time: '17:00', title: 'Shopping & Free Time', icon: Icons.shopping_bag, type: 'leisure', duration: '2h'),
      ItineraryItem(time: '19:30', title: 'Dinner Experience', icon: Icons.dinner_dining, type: 'meal', duration: '2h'),
      ItineraryItem(time: '22:00', title: 'Return to Hotel', icon: Icons.hotel, type: 'transport', duration: '30m'),
    ];

    final alternativeActivities = [
      ItineraryItem(time: '09:00', title: 'Sunrise Photography', icon: Icons.camera_alt, type: 'activity', duration: '2h'),
      ItineraryItem(time: '10:30', title: 'Local Market Exploration', icon: Icons.storefront, type: 'activity', duration: '1h 30m'),
      ItineraryItem(time: '15:00', title: 'Beach/Park Relaxation', icon: Icons.beach_access, type: 'leisure', duration: '3h'),
      ItineraryItem(time: '16:00', title: 'Boat Tour', icon: Icons.sailing, type: 'activity', duration: '2h'),
      ItineraryItem(time: '18:00', title: 'Sunset Viewpoint', icon: Icons.wb_twilight, type: 'activity', duration: '1h'),
      ItineraryItem(time: '20:00', title: 'Night Life Experience', icon: Icons.nightlife, type: 'leisure', duration: '3h'),
    ];

    for (int i = 0; i < dayCount; i++) {
      final dayActivities = <ItineraryItem>[];
      
      if (i == 0) {
        dayActivities.add(ItineraryItem(
          time: '14:00',
          title: 'Arrival & Check-in',
          icon: Icons.flight_land,
          type: 'transport',
          duration: '2h',
        ));
        dayActivities.addAll(activities.sublist(4));
      } else if (i == dayCount - 1) {
        dayActivities.addAll(activities.sublist(0, 3));
        dayActivities.add(ItineraryItem(
          time: '15:00',
          title: 'Check-out & Departure',
          icon: Icons.flight_takeoff,
          type: 'transport',
          duration: '3h',
        ));
      } else {
        if (i % 2 == 0) {
          dayActivities.addAll(activities);
        } else {
          dayActivities.add(activities[0]);
          dayActivities.addAll(alternativeActivities.sublist(0, 4));
          dayActivities.addAll(activities.sublist(5));
        }
      }

      _itinerary.add(DayItinerary(
        day: i + 1,
        date: DateTime.now().add(Duration(days: 30 + i)),
        items: dayActivities,
        highlight: i == 1 ? 'Cultural Experience Day' : (i == 2 ? 'Adventure Day' : null),
      ));
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final trip = widget.trip;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAnimatedAppBar(colors, trip),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _contentController,
                  curve: Curves.easeOutCubic,
                )),
                child: Column(
                  children: [
                    _buildQuickStats(colors, trip),
                    _buildAccommodationCard(colors),
                    _buildFlightCard(colors),
                    _buildDaySelector(colors),
                    _buildDayItinerary(colors),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(colors),
    );
  }

  Widget _buildAnimatedAppBar(AppColors colors, Trip trip) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: colors.primary,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.imageUrls.isNotEmpty)
              Image.network(
                widget.imageUrls.first,
                fit: BoxFit.cover,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    trip.color.withOpacity(0.7),
                    trip.color.withOpacity(0.95),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Opacity(
                opacity: _headerOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'FULLY PLANNED',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      trip.destination,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white.withOpacity(0.8), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          trip.countryName ?? trip.destination,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.8), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${_itinerary.length} Days',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(AppColors colors, Trip trip) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.surface, colors.surfaceVariant.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.flight_rounded, '${_itinerary.length - 1}', 'Flights', colors),
          _buildStatDivider(colors),
          _buildStatItem(Icons.hotel_rounded, '${_itinerary.length}', 'Nights', colors),
          _buildStatDivider(colors),
          _buildStatItem(Icons.local_activity_rounded, '${_itinerary.length * 5}', 'Activities', colors),
          _buildStatDivider(colors),
          _buildStatItem(Icons.attach_money_rounded, '\$2,450', 'Budget', colors),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, AppColors colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(AppColors colors) {
    return Container(
      height: 40,
      width: 1,
      color: colors.textHint.withOpacity(0.2),
    );
  }

  Widget _buildAccommodationCard(AppColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grand Plaza Hotel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < 4 ? Icons.star : Icons.star_half,
                            color: Colors.amber,
                            size: 14,
                          )),
                          const SizedBox(width: 8),
                          Text(
                            '4.5',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '\$189',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/night',
                        style: TextStyle(
                          color: colors.primary.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHotelFeature(Icons.wifi, 'Free WiFi'),
                _buildHotelFeature(Icons.pool, 'Pool'),
                _buildHotelFeature(Icons.restaurant, 'Breakfast'),
                _buildHotelFeature(Icons.spa, 'Spa'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelFeature(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFlightCard(AppColors colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colors.textHint.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.flight_rounded, color: colors.primary),
              const SizedBox(width: 12),
              Text(
                'Flight Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Confirmed',
                  style: TextStyle(
                    color: colors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'JFK',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text('New York', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('08:30 AM', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.flight_takeoff, color: colors.primary),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '8h 45m',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      'Direct',
                      style: TextStyle(color: colors.success, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.trip.cityName?.substring(0, 3).toUpperCase() ?? 'DST',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(widget.trip.cityName ?? 'Destination', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('05:15 PM', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFlightInfo(Icons.airlines, 'Delta Airlines', colors),
                _buildFlightInfo(Icons.airline_seat_recline_extra, 'Economy Plus', colors),
                _buildFlightInfo(Icons.luggage, '2x 23kg', colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightInfo(IconData icon, String text, AppColors colors) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildDaySelector(AppColors colors) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _itinerary.length,
        itemBuilder: (context, index) {
          final day = _itinerary[index];
          final isSelected = index == _selectedDay;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [colors.primary, colors.primaryLight])
                    : null,
                color: isSelected ? null : colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : colors.primary.withOpacity(0.2),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Day',
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : colors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getDayName(day.date),
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildDayItinerary(AppColors colors) {
    if (_itinerary.isEmpty) return const SizedBox();

    final day = _itinerary[_selectedDay];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Day ${day.day} Itinerary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (day.highlight != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.featuredOrange, colors.featuredPink],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    day.highlight!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ...day.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == day.items.length - 1;

            return _buildItineraryItem(item, colors, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildItineraryItem(ItineraryItem item, AppColors colors, bool isLast) {
    Color typeColor;
    switch (item.type) {
      case 'meal':
        typeColor = colors.featuredOrange;
        break;
      case 'activity':
        typeColor = colors.primary;
        break;
      case 'transport':
        typeColor = colors.featuredBlue;
        break;
      case 'leisure':
        typeColor = colors.featuredPink;
        break;
      default:
        typeColor = colors.textSecondary;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              item.time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: colors.textHint.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: typeColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: colors.textHint.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Duration: ${item.duration}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.textHint, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.primaryLight]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Edit Plan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class DayItinerary {
  final int day;
  final DateTime date;
  final List<ItineraryItem> items;
  final String? highlight;

  DayItinerary({
    required this.day,
    required this.date,
    required this.items,
    this.highlight,
  });
}

class ItineraryItem {
  final String time;
  final String title;
  final IconData icon;
  final String type;
  final String duration;

  ItineraryItem({
    required this.time,
    required this.title,
    required this.icon,
    required this.type,
    required this.duration,
  });
}
