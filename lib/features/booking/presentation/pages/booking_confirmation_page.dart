import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../data/models/hotel_model.dart';

class BookingConfirmationPage extends ConsumerStatefulWidget {
  final HotelBooking booking;

  const BookingConfirmationPage({super.key, required this.booking});

  @override
  ConsumerState<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends ConsumerState<BookingConfirmationPage>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late AnimationController _confettiController;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _checkController.forward().then((_) {
      _contentController.forward();
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _downloadVoucher() async {
    final booking = widget.booking;
    final colors = ref.read(appColorsProvider);
    final nights = booking.checkOut.difference(booking.checkIn).inDays;
    
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                color: PdfColors.blue800,
                child: pw.Column(
                  children: [
                    pw.Text('HOTEL BOOKING VOUCHER', 
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 6),
                    pw.Text('Confirmation: ${booking.id.substring(0, 8).toUpperCase()}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Hotel Info
              pw.Text('HOTEL DETAILS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
              pw.SizedBox(height: 8),
              pw.Text(booking.hotel.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('${booking.hotel.address}'),
              pw.Text('${booking.hotel.city}, ${booking.hotel.country}'),
              pw.SizedBox(height: 16),
              
              // Booking Details Table
              pw.Text('RESERVATION DETAILS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Room Type')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(booking.room.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Check-in')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(DateFormat('EEEE, MMM d, yyyy').format(booking.checkIn), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Check-out')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(DateFormat('EEEE, MMM d, yyyy').format(booking.checkOut), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Duration')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$nights night${nights > 1 ? 's' : ''}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Guests')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${booking.guests}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ]),
                ],
              ),
              pw.SizedBox(height: 16),
              
              // Guest Info
              pw.Text('GUEST INFORMATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
              pw.SizedBox(height: 8),
              pw.Text('Name: ${booking.guestInfo.firstName} ${booking.guestInfo.lastName}'),
              pw.Text('Email: ${booking.guestInfo.email}'),
              pw.Text('Phone: ${booking.guestInfo.phone}'),
              pw.SizedBox(height: 16),
              
              // Payment Summary
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                color: PdfColors.green50,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL PAID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${(booking.totalPrice * 1.1).toInt()}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                color: PdfColors.grey100,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Important Information:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text('• Present this voucher at check-in', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('• Check-in: ${booking.hotel.checkInTime} | Check-out: ${booking.hotel.checkOutTime}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('• Please contact the hotel for any special requests', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/voucher_${booking.id.substring(0, 8)}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Voucher saved successfully!'),
            backgroundColor: colors.success,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => OpenFile.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving voucher: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final booking = widget.booking;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildSuccessAnimation(colors),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _contentController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _contentController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: Column(
                          children: [
                            Text(
                              'Booking Confirmed!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your reservation has been successfully made',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            _buildBookingCard(booking, colors),
                            const SizedBox(height: 24),
                            _buildBookingDetails(booking, colors),
                            const SizedBox(height: 24),
                            _buildGuestInfo(booking, colors),
                            const SizedBox(height: 24),
                            _buildPaymentInfo(booking, colors),
                            const SizedBox(height: 32),
                            _buildActionButtons(colors),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ..._buildConfetti(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation(AppColors colors) {
    return AnimatedBuilder(
      animation: _checkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.success, colors.success.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.success.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 60 * _checkAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(HotelBooking booking, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  booking.hotel.photos.first,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.hotel.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.room.name,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: colors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${booking.hotel.city}, ${booking.hotel.country}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withOpacity(0.08),
                  colors.primaryLight.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.confirmation_number_outlined, color: colors.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      booking.id,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: booking.status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.displayName,
                    style: TextStyle(
                      color: booking.status.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(HotelBooking booking, AppColors colors) {
    final dateFormat = DateFormat('EEE, MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.login_rounded,
                  'Check-in',
                  dateFormat.format(booking.checkIn),
                  booking.hotel.checkInTime,
                  colors,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: colors.primary.withOpacity(0.1),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.logout_rounded,
                  'Check-out',
                  dateFormat.format(booking.checkOut),
                  booking.hotel.checkOutTime,
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: colors.primary.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.nights_stay_outlined, '${booking.nights} Nights', colors),
              _buildStatItem(Icons.person_outline_rounded, '${booking.guests} Guests', colors),
              _buildStatItem(Icons.door_back_door_outlined, '${booking.rooms} Rooms', colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    String time,
    AppColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          Text(
            'From $time',
            style: TextStyle(
              color: colors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, AppColors colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestInfo(HotelBooking booking, AppColors colors) {
    final guest = booking.guestInfo;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline_rounded, '${guest.firstName} ${guest.lastName}', colors),
          _buildInfoRow(Icons.email_outlined, guest.email, colors),
          _buildInfoRow(Icons.phone_outlined, guest.phone, colors),
          if (guest.specialRequests != null && guest.specialRequests!.isNotEmpty)
            _buildInfoRow(Icons.note_outlined, guest.specialRequests!, colors),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(HotelBooking booking, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPaymentRow('Room Rate (${booking.nights} nights x ${booking.rooms} rooms)',
            '\$${(booking.room.pricePerNight * booking.nights * booking.rooms).toInt()}'),
          _buildPaymentRow('Taxes & Fees', '\$${(booking.totalPrice * 0.1).toInt()}'),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Paid',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '\$${(booking.totalPrice * 1.1).toInt()}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (booking.paymentInfo != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(booking.paymentInfo!.method.icon, color: Colors.white.withOpacity(0.8), size: 18),
                const SizedBox(width: 8),
                Text(
                  '${booking.paymentInfo!.method.displayName} ending in ${booking.paymentInfo!.maskedCardNumber.split(' ').last}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppColors colors) {
    return Column(
      children: [
        GestureDetector(
          onTap: _downloadVoucher,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_rounded, color: colors.surface),
                const SizedBox(width: 10),
                Text(
                  'Download Voucher',
                  style: TextStyle(
                    color: colors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share_rounded, color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: colors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: colors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildConfetti(AppColors colors) {
    final random = math.Random();
    final confettiColors = [
      colors.primary,
      colors.primaryLight,
      colors.featuredPink,
      colors.featuredBlue,
      colors.featuredOrange,
      colors.success,
    ];

    return List.generate(30, (index) {
      final left = random.nextDouble() * MediaQuery.of(context).size.width;
      final delay = random.nextDouble() * 0.5;
      final color = confettiColors[random.nextInt(confettiColors.length)];
      final size = 8.0 + random.nextDouble() * 8;

      return AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          final progress = (_confettiController.value - delay).clamp(0.0, 1.0);
          if (progress == 0) return const SizedBox.shrink();

          final top = progress * MediaQuery.of(context).size.height * 1.2;
          final rotation = progress * math.pi * 4 * (index.isEven ? 1 : -1);
          final opacity = (1 - progress).clamp(0.0, 1.0);

          return Positioned(
            left: left + math.sin(progress * math.pi * 2) * 30,
            top: top - 50,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size * (index % 3 == 0 ? 1 : 0.6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(index % 2 == 0 ? size : 2),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
