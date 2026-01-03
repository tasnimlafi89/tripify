import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/domain/entities/activity.dart';
import 'package:frontend/features/home/presentation/viewmodels/activity_provider.dart';
import 'activity_detail_page.dart';

class ActivityMapPage extends ConsumerStatefulWidget {
  final String cityName;
  final String countryName;
  final double? latitude;
  final double? longitude;

  const ActivityMapPage({
    super.key,
    required this.cityName,
    required this.countryName,
    this.latitude,
    this.longitude,
  });

  @override
  ConsumerState<ActivityMapPage> createState() => _ActivityMapPageState();

  static const Map<String, LatLng> cityCoordinates = {
    'paris': LatLng(48.8566, 2.3522),
    'london': LatLng(51.5074, -0.1278),
    'new york': LatLng(40.7128, -74.0060),
    'tokyo': LatLng(35.6762, 139.6503),
    'dubai': LatLng(25.2048, 55.2708),
    'barcelona': LatLng(41.3851, 2.1734),
    'rome': LatLng(41.9028, 12.4964),
    'sousse': LatLng(35.8288, 10.6405),
    'tunis': LatLng(36.8065, 10.1815),
    'bali': LatLng(-8.4095, 115.1889),
    'santorini': LatLng(36.3932, 25.4615),
    'maldives': LatLng(3.2028, 73.2207),
    'sydney': LatLng(-33.8688, 151.2093),
    'cairo': LatLng(30.0444, 31.2357),
    'marrakech': LatLng(31.6295, -7.9811),
    'amsterdam': LatLng(52.3676, 4.9041),
    'berlin': LatLng(52.5200, 13.4050),
    'vienna': LatLng(48.2082, 16.3738),
    'prague': LatLng(50.0755, 14.4378),
    'lisbon': LatLng(38.7223, -9.1393),
    'istanbul': LatLng(41.0082, 28.9784),
    'bangkok': LatLng(13.7563, 100.5018),
    'singapore': LatLng(1.3521, 103.8198),
    'hong kong': LatLng(22.3193, 114.1694),
    'seoul': LatLng(37.5665, 126.9780),
    'los angeles': LatLng(34.0522, -118.2437),
    'miami': LatLng(25.7617, -80.1918),
    'cancun': LatLng(21.1619, -86.8515),
    'rio de janeiro': LatLng(-22.9068, -43.1729),
    'cape town': LatLng(-33.9249, 18.4241),
  };
}

class _ActivityMapPageState extends ConsumerState<ActivityMapPage>
    with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final PageController _pageController = PageController(viewportFraction: 0.85);
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  bool _isExpanded = false;
  String _searchQuery = '';
  ActivityCategory? _selectedCategory;

  LatLng _getInitialCenter(List<Activity> activities) {
    if (widget.latitude != null && widget.longitude != null) {
      return LatLng(widget.latitude!, widget.longitude!);
    }

    final cityLower = widget.cityName.toLowerCase();
    final cityCoord = ActivityMapPage.cityCoordinates[cityLower];
    if (cityCoord != null) return cityCoord;

    if (activities.isNotEmpty) {
      return LatLng(activities.first.latitude, activities.first.longitude);
    }

    return const LatLng(48.8566, 2.3522);
  }

  List<Activity> _filterActivities(List<Activity> activities) {
    var filtered = activities;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((a) =>
              a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.category.displayName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((a) => a.category == _selectedCategory).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
      _fadeController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activitiesProvider.notifier).loadActivities(
            cityName: widget.cityName,
            countryName: widget.countryName,
            latitude: widget.latitude,
            longitude: widget.longitude,
          );
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onActivitySelected(int index, List<Activity> activities) {
    setState(() => _selectedIndex = index);

    final activity = activities[index];
    _mapController.move(
      LatLng(activity.latitude, activity.longitude),
      14,
    );

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final activitiesState = ref.watch(activitiesProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: colors.backgroundGradient,
        ),
        child: SafeArea(
          child: activitiesState.isLoading
              ? _buildLoading(colors)
              : activitiesState.error != null
                  ? _buildError(activitiesState.error!, colors)
                  : _buildContent(_filterActivities(activitiesState.activities), colors),
        ),
      ),
    );
  }

  Widget _buildContent(List<Activity> activities, AppColors colors) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _getInitialCenter(activities),
            initialZoom: 13,
            onTap: (_, __) {
              if (_isExpanded) _toggleExpanded();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: colors.brightness == Brightness.dark
                  ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                  : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            MarkerLayer(
              markers: activities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                final isSelected = index == _selectedIndex;

                return Marker(
                  point: LatLng(activity.latitude, activity.longitude),
                  width: isSelected ? 60 : 50,
                  height: isSelected ? 60 : 50,
                  child: GestureDetector(
                    onTap: () => _onActivitySelected(index, activities),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = isSelected ? 1.0 + (_pulseController.value * 0.1) : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: _buildMarker(activity, isSelected, colors),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHeader(colors),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildActivityCards(activities, colors),
          ),
        ),

        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(color: Colors.black54),
            ),
          ),

        if (_isExpanded)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildExpandedList(activities, colors),
          ),
      ],
    );
  }

  Widget _buildMarker(Activity activity, bool isSelected, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? activity.category.color : colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : activity.category.color,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: activity.category.color.withOpacity(isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 15 : 8,
            spreadRadius: isSelected ? 3 : 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          activity.category.icon,
          color: isSelected ? Colors.white : activity.category.color,
          size: isSelected ? 28 : 22,
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.background,
            colors.background.withOpacity(0.8),
            colors.background.withOpacity(0),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search activities...',
                      hintStyle: TextStyle(color: colors.textHint),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: colors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showCategoryFilter(colors),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedCategory != null ? _selectedCategory!.color : colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: _selectedCategory != null ? Colors.white : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip(null, 'All', colors),
                ...ActivityCategory.values.map((category) =>
                    _buildCategoryChip(category, category.displayName, colors)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ActivityCategory? category, String label, AppColors colors) {
    final isSelected = _selectedCategory == category;
    final chipColor = category?.color ?? colors.primary;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != null) ...[
              Icon(
                category.icon,
                size: 16,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCards(List<Activity> activities, AppColors colors) {
    if (activities.isEmpty) {
      return Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No activities found in this area',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textHint.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${activities.length} activities',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: colors.surface,
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => _onActivitySelected(index, activities),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityCard(activity, index == _selectedIndex, colors);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity, bool isSelected, AppColors colors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: activity)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: isSelected ? 8 : 16,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activity.category.color : colors.primary.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: activity.category.color.withOpacity(isSelected ? 0.3 : 0.1),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: activity.imageUrls.isNotEmpty
                  ? Image.network(
                      activity.imageUrls.first,
                      width: 120,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(activity, colors),
                    )
                  : _buildPlaceholderImage(activity, colors),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: activity.category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(activity.category.icon, size: 12, color: activity.category.color),
                              const SizedBox(width: 4),
                              Text(
                                activity.category.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: activity.category.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          activity.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          activity.formattedDuration,
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activity.formattedPrice,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: activity.category.color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: activity.category.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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

  Widget _buildPlaceholderImage(Activity activity, AppColors colors) {
    return Container(
      width: 120,
      color: activity.category.color.withOpacity(0.2),
      child: Center(
        child: Icon(
          activity.category.icon,
          size: 40,
          color: activity.category.color,
        ),
      ),
    );
  }

  Widget _buildExpandedList(List<Activity> activities, AppColors colors) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'All Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${activities.length} results',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _buildListActivityCard(activity, colors),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListActivityCard(Activity activity, AppColors colors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: activity)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: activity.category.color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: activity.category.color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: activity.imageUrls.isNotEmpty
                  ? Image.network(
                      activity.imageUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: activity.category.color.withOpacity(0.2),
                        child: Icon(activity.category.icon, color: activity.category.color),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: activity.category.color.withOpacity(0.2),
                      child: Icon(activity.category.icon, color: activity.category.color),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: activity.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity.category.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: activity.category.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.rating} (${activity.reviewCount})',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        activity.formattedDuration,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activity.formattedPrice,
                        style: TextStyle(
                          color: activity.category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textHint.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption(null, 'All Categories', Icons.apps, colors),
            ...ActivityCategory.values.map((category) =>
                _buildFilterOption(category, category.displayName, category.icon, colors)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
      ActivityCategory? category, String label, IconData icon, AppColors colors) {
    final isSelected = _selectedCategory == category;
    final itemColor = category?.color ?? colors.primary;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? itemColor.withOpacity(0.1) : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? itemColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? itemColor : colors.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? itemColor : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle_rounded, color: itemColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Finding activities in ${widget.cityName}...',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(activitiesProvider.notifier).loadActivities(
                    cityName: widget.cityName,
                    countryName: widget.countryName,
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
