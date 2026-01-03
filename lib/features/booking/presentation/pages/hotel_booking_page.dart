import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:intl/intl.dart';
import '../../data/models/hotel_model.dart';
import '../providers/hotel_provider.dart';
import 'booking_confirmation_page.dart';

class HotelBookingPage extends ConsumerStatefulWidget {
  final Hotel hotel;
  final HotelRoom room;

  const HotelBookingPage({
    super.key,
    required this.hotel,
    required this.room,
  });

  @override
  ConsumerState<HotelBookingPage> createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends ConsumerState<HotelBookingPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _countryCode = '+1';

  @override
  void initState() {
    super.initState();
    _setDefaultCountryCode();
  }

  void _setDefaultCountryCode() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final countryCodeMap = {
      'US': '+1', 'CA': '+1', 'GB': '+44', 'FR': '+33', 'DE': '+49',
      'ES': '+34', 'IT': '+39', 'PT': '+351', 'NL': '+31', 'BE': '+32',
      'CH': '+41', 'AT': '+43', 'AU': '+61', 'NZ': '+64', 'JP': '+81',
      'CN': '+86', 'KR': '+82', 'IN': '+91', 'BR': '+55', 'MX': '+52',
      'AR': '+54', 'CL': '+56', 'CO': '+57', 'PE': '+51', 'VE': '+58',
      'RU': '+7', 'UA': '+380', 'PL': '+48', 'TR': '+90', 'SA': '+966',
      'AE': '+971', 'EG': '+20', 'ZA': '+27', 'NG': '+234', 'KE': '+254',
      'MA': '+212', 'TN': '+216', 'DZ': '+213',
    };
    setState(() {
      _countryCode = countryCodeMap[locale.countryCode] ?? '+1';
      _phoneController.text = _countryCode;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    final formNotifier = ref.read(bookingFormProvider.notifier);
    final service = ref.read(hotelServiceProvider);
    final checkIn = ref.read(checkInDateProvider);
    final checkOut = ref.read(checkOutDateProvider);
    final guests = ref.read(guestCountProvider);
    final rooms = ref.read(roomCountProvider);

    formNotifier.updateFirstName(_firstNameController.text.isNotEmpty ? _firstNameController.text : 'Guest');
    formNotifier.updateLastName(_lastNameController.text.isNotEmpty ? _lastNameController.text : 'User');
    formNotifier.updateEmail(_emailController.text.isNotEmpty ? _emailController.text : 'guest@email.com');
    formNotifier.updatePhone(_phoneController.text.isNotEmpty ? _phoneController.text : '+1234567890');

    final booking = await formNotifier.submitBooking(
      service: service,
      hotel: widget.hotel,
      room: widget.room,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      rooms: rooms,
      skipValidation: true,
    );

    if (booking != null && mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => BookingConfirmationPage(booking: booking)),
      );
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final checkIn = ref.watch(checkInDateProvider);
    final checkOut = ref.watch(checkOutDateProvider);
    final guests = ref.watch(guestCountProvider);
    final nights = checkOut.difference(checkIn).inDays;
    final totalPrice = widget.room.pricePerNight * nights;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Hotel'),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.hotel.photos.first,
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
                              widget.hotel.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.room.name,
                              style: TextStyle(color: colors.textSecondary),
                            ),
                            Text(
                              '${widget.hotel.city}, ${widget.hotel.country}',
                              style: TextStyle(color: colors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date Selection
              Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              const SizedBox(height: 12),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDateRow('Check-in', checkIn, colors, true),
                      const Divider(),
                      _buildDateRow('Check-out', checkOut, colors, false),
                      const Divider(),
                      _buildGuestRow(guests, colors),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Guest Info
              Text('Guest Information (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              const SizedBox(height: 12),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price Summary
              Card(
                color: colors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${widget.room.pricePerNight.toInt()} x $nights nights', style: const TextStyle(color: Colors.white)),
                          Text('\$${totalPrice.toInt()}', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Taxes & Fees', style: TextStyle(color: Colors.white)),
                          Text('\$${(totalPrice * 0.1).toInt()}', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const Divider(color: Colors.white54),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('\$${(totalPrice * 1.1).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, AppColors colors, bool isCheckIn) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          if (isCheckIn) {
            ref.read(checkInDateProvider.notifier).state = picked;
          } else {
            ref.read(checkOutDateProvider.notifier).state = picked;
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: colors.primary),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: colors.textPrimary)),
              ],
            ),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestRow(int guests, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: colors.primary),
              const SizedBox(width: 12),
              Text('Guests', style: TextStyle(color: colors.textPrimary)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: colors.primary),
                onPressed: guests > 1 ? () => ref.read(guestCountProvider.notifier).state-- : null,
              ),
              Text('$guests', style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary)),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: colors.primary),
                onPressed: guests < 10 ? () => ref.read(guestCountProvider.notifier).state++ : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
