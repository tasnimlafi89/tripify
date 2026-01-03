import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/theme/theme.dart';
import '../../data/models/hotel_model.dart';
import '../providers/hotel_provider.dart';
import 'hotel_detail_page.dart';

class HotelMapPage extends ConsumerStatefulWidget {
  final String? city;
  
  const HotelMapPage({super.key, this.city});

  @override
  ConsumerState<HotelMapPage> createState() => _HotelMapPageState();
  
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
  };
}

class _HotelMapPageState extends ConsumerState<HotelMapPage> with TickerProviderStateMixin {
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
  
  LatLng _getInitialCenter(List<Hotel> hotels) {
    // First, try to use city parameter
    if (widget.city != null && widget.city!.isNotEmpty) {
      final cityLower = widget.city!.toLowerCase();
      final cityCoord = HotelMapPage.cityCoordinates[cityLower];
      if (cityCoord != null) return cityCoord;
    }
    
    // Then, try first hotel's coordinates
    if (hotels.isNotEmpty) {
      return LatLng(hotels.first.latitude, hotels.first.longitude);
    }
    
    // Default to Paris
    return const LatLng(48.8566, 2.3522);
  }

  List<Hotel> _filterHotels(List<Hotel> hotels) {
    var filtered = hotels;
    
    if (widget.city != null && widget.city!.isNotEmpty) {
      filtered = filtered.where((h) => 
        h.city.toLowerCase().contains(widget.city!.toLowerCase()) ||
        h.country.toLowerCase().contains(widget.city!.toLowerCase())
      ).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((h) =>
        h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        h.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        h.address.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
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

  void _onHotelSelected(int index, List<Hotel> hotels) {
    setState(() => _selectedIndex = index);
    ref.read(selectedHotelIndexProvider.notifier).state = index;
    
    final hotel = hotels[index];
    _mapController.move(
      LatLng(hotel.latitude, hotel.longitude),
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
    final hotelsAsync = ref.watch(sortedHotelsProvider);
    final sortOption = ref.watch(sortOptionProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: colors.backgroundGradient,
        ),
        child: SafeArea(
          child: hotelsAsync.when(
            data: (allHotels) {
              final hotels = _filterHotels(allHotels);
              return _buildContent(hotels, colors, sortOption);
            },
            loading: () => _buildLoading(colors),
            error: (error, _) => _buildError(error, colors),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Hotel> hotels, AppColors colors, String sortOption) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _getInitialCenter(hotels),
            initialZoom: 12,
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
              markers: hotels.asMap().entries.map((entry) {
                final index = entry.key;
                final hotel = entry.value;
                final isSelected = index == _selectedIndex;
                
                return Marker(
                  point: LatLng(hotel.latitude, hotel.longitude),
                  width: isSelected ? 60 : 50,
                  height: isSelected ? 60 : 50,
                  child: GestureDetector(
                    onTap: () => _onHotelSelected(index, hotels),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = isSelected 
                          ? 1.0 + (_pulseController.value * 0.1)
                          : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: _buildMarker(hotel, isSelected, colors),
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
            child: _buildHeader(colors, sortOption),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildHotelCards(hotels, colors),
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
            child: _buildExpandedHotelList(hotels, colors),
          ),
      ],
    );
  }

  Widget _buildMarker(Hotel hotel, bool isSelected, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? colors.primary : colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isSelected 
              ? colors.primary.withOpacity(0.4)
              : Colors.black.withOpacity(0.2),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected ? colors.primaryLight : colors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel_rounded,
            color: isSelected ? colors.surface : colors.primary,
            size: isSelected ? 24 : 20,
          ),
          if (isSelected)
            Text(
              hotel.formattedPrice,
              style: TextStyle(
                color: colors.surface,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors, String sortOption) {
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
              _buildGlassButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
                colors: colors,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Hotels',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.city ?? 'All Locations',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildGlassButton(
                icon: Icons.tune_rounded,
                onTap: () => _showSortOptions(colors),
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBar(colors),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colors.primary.withOpacity(0.1),
          ),
        ),
        child: Icon(icon, color: colors.primary, size: 22),
      ),
    );
  }

  Widget _buildSearchBar(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: colors.searchBarBorder),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search hotels...',
          hintStyle: TextStyle(color: colors.textHint),
          prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: colors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildHotelCards(List<Hotel> hotels, AppColors colors) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.15),
                  blurRadius: 20,
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
                  '${hotels.length} Hotels Found',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: hotels.length,
            onPageChanged: (index) => _onHotelSelected(index, hotels),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index).abs();
                    value = (1 - (value * 0.2)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOut.transform(value),
                    child: Opacity(
                      opacity: Curves.easeOut.transform(value),
                      child: child,
                    ),
                  );
                },
                child: _buildHotelCard(hotels[index], colors, index == _selectedIndex),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelCard(Hotel hotel, AppColors colors, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedHotelProvider.notifier).state = hotel;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HotelDetailPage(hotel: hotel),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? colors.primary.withOpacity(0.25)
                : colors.primary.withOpacity(0.1),
              blurRadius: isSelected ? 25 : 15,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isSelected 
              ? colors.primary.withOpacity(0.3)
              : colors.primary.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'hotel_image_${hotel.id}',
              child: Container(
                width: 120,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                  image: DecorationImage(
                    image: NetworkImage(hotel.photos.first),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (hotel.isFeatured)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.featuredOrange, colors.featuredPink],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (hotel.discountPercentage > 0)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${hotel.discountPercentage.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded, color: colors.warning, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                hotel.rating.toString(),
                                style: TextStyle(
                                  color: colors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${hotel.reviewCount} reviews',
                            style: TextStyle(
                              color: colors.textHint,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hotel.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.address,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        ...hotel.facilities.take(3).map((f) => 
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(f.icon, size: 16, color: colors.primary.withOpacity(0.7)),
                          ),
                        ),
                        if (hotel.facilities.length > 3)
                          Text(
                            '+${hotel.facilities.length - 3}',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (hotel.discountPercentage > 0) ...[
                          Text(
                            hotel.originalPrice,
                            style: TextStyle(
                              color: colors.textHint,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          hotel.formattedPrice,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          ' / night',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
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

  Widget _buildExpandedHotelList(List<Hotel> hotels, AppColors colors) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7 * value,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.all(16),
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'All Hotels',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${hotels.length} results',
                  style: TextStyle(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
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
                  child: _buildListHotelCard(hotel, colors),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHotelCard(Hotel hotel, AppColors colors) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedHotelProvider.notifier).state = hotel;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HotelDetailPage(hotel: hotel)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hotel.photos.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
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
                      Icon(Icons.star_rounded, color: colors.warning, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.rating} (${hotel.reviewCount})',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hotel.formattedPrice,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
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

  void _showSortOptions(AppColors colors) {
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
              'Sort By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('rating', 'Top Rated', Icons.star_rounded, colors),
            _buildSortOption('price_low', 'Price: Low to High', Icons.arrow_upward_rounded, colors),
            _buildSortOption('price_high', 'Price: High to Low', Icons.arrow_downward_rounded, colors),
            _buildSortOption('reviews', 'Most Reviews', Icons.reviews_rounded, colors),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon, AppColors colors) {
    final currentSort = ref.watch(sortOptionProvider);
    final isSelected = currentSort == value;

    return GestureDetector(
      onTap: () {
        ref.read(sortOptionProvider.notifier).state = value;
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.1) : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colors.primary : colors.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.primary : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.primary),
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
            'Finding best hotels...',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error, AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load hotels',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
