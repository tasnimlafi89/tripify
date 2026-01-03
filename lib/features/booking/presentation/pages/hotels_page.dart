import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import '../../data/models/hotel_model.dart';
import '../providers/hotel_provider.dart';
import 'hotel_detail_page.dart';
import 'hotel_map_page.dart';

class HotelsPage extends ConsumerStatefulWidget {
  final String? city;
  final String? country;

  const HotelsPage({super.key, this.city, this.country});

  @override
  ConsumerState<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends ConsumerState<HotelsPage> {
  bool _bookingCompleted = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hotel> _filterHotels(List<Hotel> hotels) {
    var filtered = hotels;
    
    // Filter by city if provided
    if (widget.city != null && widget.city!.isNotEmpty) {
      filtered = filtered.where((h) => 
        h.city.toLowerCase().contains(widget.city!.toLowerCase()) ||
        h.country.toLowerCase().contains(widget.city!.toLowerCase())
      ).toList();
    }
    
    // Filter by search query
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
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final hotelsAsync = ref.watch(sortedHotelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city != null ? 'Hotels in ${widget.city}' : 'Find Hotels'),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _bookingCompleted),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'View on Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HotelMapPage(city: widget.city)),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search hotels...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            // Hotels List
            Expanded(
              child: hotelsAsync.when(
                data: (hotels) => _buildHotelList(hotels, colors),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: colors.error),
                      const SizedBox(height: 16),
                      Text('Error loading hotels', style: TextStyle(color: colors.textPrimary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(sortedHotelsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelList(List<Hotel> allHotels, AppColors colors) {
    final hotels = _filterHotels(allHotels);
    
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel, size: 64, color: colors.textHint),
            const SizedBox(height: 16),
            Text(
              widget.city != null 
                ? 'No hotels found in ${widget.city}'
                : 'No hotels found',
              style: TextStyle(color: colors.textSecondary, fontSize: 16),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(color: colors.textHint),
              ),
            ],
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        return _buildHotelCard(hotel, colors);
      },
    );
  }

  Widget _buildHotelCard(Hotel hotel, AppColors colors) {
    return GestureDetector(
      onTap: () async {
        ref.read(selectedHotelProvider.notifier).state = hotel;
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => HotelDetailPage(hotel: hotel)),
        );
        if (result == true) {
          setState(() => _bookingCompleted = true);
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                hotel.photos.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Hotel Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              hotel.rating.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.city}, ${hotel.country}',
                        style: TextStyle(color: colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Facilities icons
                      Row(
                        children: hotel.facilities.take(3).map((f) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(f.icon, size: 18, color: colors.primary),
                          );
                        }).toList(),
                      ),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hotel.formattedPrice,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(fontSize: 10, color: colors.textSecondary),
                          ),
                        ],
                      ),
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
}
