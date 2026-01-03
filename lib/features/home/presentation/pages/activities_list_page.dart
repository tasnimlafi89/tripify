import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/domain/entities/activity.dart';
import 'package:frontend/features/home/presentation/viewmodels/activity_provider.dart';
import 'package:frontend/features/home/presentation/pages/activity_detail_page.dart';

class ActivitiesListPage extends ConsumerStatefulWidget {
  final String cityName;
  final String countryName;
  final double? latitude;
  final double? longitude;

  const ActivitiesListPage({
    super.key,
    required this.cityName,
    required this.countryName,
    this.latitude,
    this.longitude,
  });

  @override
  ConsumerState<ActivitiesListPage> createState() => _ActivitiesListPageState();
}

class _ActivitiesListPageState extends ConsumerState<ActivitiesListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ActivityCategory.values.length + 1, vsync: this);
    
    // Load activities when page opens
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
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final activitiesState = ref.watch(activitiesProvider);
    final filteredActivities = ref.watch(filteredActivitiesProvider);
    final selectedCategory = ref.watch(selectedActivityCategoryProvider);
    final sortOption = ref.watch(activitySortOptionProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: colors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => setState(() => _showFilters = !_showFilters),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primary, colors.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activities in',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white.withOpacity(0.8), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.countryName,
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
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(activitySearchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search activities...',
                  hintStyle: TextStyle(color: colors.textHint),
                  prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: colors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(activitySearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),

          // Category Filter Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(null, 'All', colors, selectedCategory),
                  ...ActivityCategory.values.map((category) =>
                    _buildCategoryChip(category, category.displayName, colors, selectedCategory),
                  ),
                ],
              ),
            ),
          ),

          // Filters Panel (collapsible)
          if (_showFilters)
            SliverToBoxAdapter(
              child: _buildFiltersPanel(colors, sortOption),
            ),

          // Results Count & Sort
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredActivities.length} activities found',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  PopupMenuButton<ActivitySortOption>(
                    initialValue: sortOption,
                    onSelected: (value) {
                      ref.read(activitySortOptionProvider.notifier).state = value;
                    },
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: colors.primary, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _getSortLabel(sortOption),
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: ActivitySortOption.rating,
                        child: Text('Rating'),
                      ),
                      const PopupMenuItem(
                        value: ActivitySortOption.priceAsc,
                        child: Text('Price: Low to High'),
                      ),
                      const PopupMenuItem(
                        value: ActivitySortOption.priceDesc,
                        child: Text('Price: High to Low'),
                      ),
                      const PopupMenuItem(
                        value: ActivitySortOption.duration,
                        child: Text('Duration'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading / Error / Content
          if (activitiesState.isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Finding activities...',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else if (activitiesState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: colors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading activities',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(activitiesProvider.notifier).loadActivities(
                          cityName: widget.cityName,
                          countryName: widget.countryName,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredActivities.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: colors.textHint),
                    const SizedBox(height: 16),
                    Text(
                      'No activities found',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final activity = filteredActivities[index];
                    return _buildActivityCard(activity, colors);
                  },
                  childCount: filteredActivities.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    ActivityCategory? category,
    String label,
    AppColors colors,
    ActivityCategory? selectedCategory,
  ) {
    final isSelected = category == selectedCategory;
    final chipColor = category?.color ?? colors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
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
            Text(label),
          ],
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colors.surface,
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        onSelected: (selected) {
          ref.read(selectedActivityCategoryProvider.notifier).state =
              selected ? category : null;
        },
      ),
    );
  }

  Widget _buildFiltersPanel(AppColors colors, ActivitySortOption sortOption) {
    final priceRange = ref.watch(activityPriceRangeProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(priceRange.$1, priceRange.$2),
            min: 0,
            max: 500,
            divisions: 50,
            labels: RangeLabels(
              '\$${priceRange.$1.toInt()}',
              '\$${priceRange.$2.toInt()}',
            ),
            activeColor: colors.primary,
            onChanged: (values) {
              ref.read(activityPriceRangeProvider.notifier).state = (values.start, values.end);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${priceRange.$1.toInt()}', style: TextStyle(color: colors.textSecondary)),
              Text('\$${priceRange.$2.toInt()}', style: TextStyle(color: colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(activityPriceRangeProvider.notifier).state = (0, 500);
                    ref.read(selectedActivityCategoryProvider.notifier).state = null;
                    ref.read(activitySearchQueryProvider.notifier).state = '';
                    _searchController.clear();
                  },
                  child: const Text('Reset Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity, AppColors colors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityDetailPage(activity: activity),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: activity.category.color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: activity.imageUrls.isNotEmpty
                      ? Image.network(
                          activity.imageUrls.first,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(colors, activity),
                        )
                      : _buildPlaceholderImage(colors, activity),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: activity.category.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(activity.category.icon, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          activity.category.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(activitiesProvider.notifier).toggleFavorite(activity.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        activity.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: activity.isFavorite ? Colors.red : colors.textHint,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                // Price badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activity.formattedPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.description,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Rating and duration
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              activity.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${activity.reviewCount})',
                              style: TextStyle(
                                color: colors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Duration
                      Icon(Icons.schedule, size: 16, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        activity.formattedDuration,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      // Arrow
                      Icon(Icons.arrow_forward_ios, size: 16, color: colors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(AppColors colors, Activity activity) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            activity.category.color.withOpacity(0.3),
            activity.category.color.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          activity.category.icon,
          size: 60,
          color: activity.category.color,
        ),
      ),
    );
  }

  String _getSortLabel(ActivitySortOption option) {
    switch (option) {
      case ActivitySortOption.rating:
        return 'Rating';
      case ActivitySortOption.priceAsc:
        return 'Price ↑';
      case ActivitySortOption.priceDesc:
        return 'Price ↓';
      case ActivitySortOption.duration:
        return 'Duration';
    }
  }
}
