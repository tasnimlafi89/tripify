import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import '../../data/models/hotel_model.dart';
import '../providers/hotel_provider.dart';
import 'hotel_booking_page.dart';

class HotelDetailPage extends ConsumerStatefulWidget {
  final Hotel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  ConsumerState<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends ConsumerState<HotelDetailPage> {
  int _selectedRoomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final hotel = widget.hotel;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // App Bar with Image
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  hotel.photos.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Name and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hotel.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.warning,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                hotel.rating.toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, color: colors.textSecondary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.city}, ${hotel.country}',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Text(
                      hotel.formattedPrice,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    Text('per night', style: TextStyle(color: colors.textSecondary)),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'About',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hotel.description,
                      style: TextStyle(color: colors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Facilities
                    Text(
                      'Facilities',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: hotel.facilities.map((facility) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(facility.icon, color: colors.primary, size: 18),
                              const SizedBox(width: 6),
                              Text(facility.name, style: TextStyle(color: colors.textPrimary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Rooms
                    Text(
                      'Available Rooms',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ...hotel.rooms.asMap().entries.map((entry) {
                      final index = entry.key;
                      final room = entry.value;
                      final isSelected = index == _selectedRoomIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedRoomIndex = index);
                          ref.read(selectedRoomProvider.notifier).state = room;
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? colors.primary : colors.textHint.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${room.maxGuests} guests • ${room.size.toInt()} sqm',
                                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${room.pricePerNight.toInt()}/night',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Book Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              final selectedRoom = hotel.rooms[_selectedRoomIndex];
              ref.read(selectedRoomProvider.notifier).state = selectedRoom;
              
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => HotelBookingPage(hotel: hotel, room: selectedRoom),
                ),
              );
              
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
