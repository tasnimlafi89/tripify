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
import 'package:frontend/features/home/domain/entities/activity.dart';

class ActivityBookingConfirmationPage extends ConsumerStatefulWidget {
  final ActivityBooking booking;
  final Activity activity;

  const ActivityBookingConfirmationPage({
    super.key,
    required this.booking,
    required this.activity,
  });

  @override
  ConsumerState<ActivityBookingConfirmationPage> createState() =>
      _ActivityBookingConfirmationPageState();
}

class _ActivityBookingConfirmationPageState
    extends ConsumerState<ActivityBookingConfirmationPage>
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
    final activity = widget.activity;
    final colors = ref.read(appColorsProvider);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                color: PdfColor.fromInt(activity.category.color.value),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'ACTIVITY BOOKING VOUCHER',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Confirmation: ${booking.id.substring(0, 8).toUpperCase()}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'ACTIVITY DETAILS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                activity.name,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(activity.category.displayName),
              pw.Text('${activity.cityName}, ${activity.countryName}'),
              pw.SizedBox(height: 16),
              pw.Text(
                'BOOKING DETAILS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Activity Date'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        DateFormat('EEEE, MMM d, yyyy').format(booking.activityDate),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Participants'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${booking.numberOfParticipants}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Duration'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        activity.formattedDuration,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ]),
                  if (booking.specialRequests != null)
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Special Requests'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          booking.specialRequests!,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ]),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                color: PdfColors.green50,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL PAID',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                color: PdfColors.grey100,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Important Information:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '• Present this voucher at the meeting point',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      '• Arrive 15 minutes before the scheduled time',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      '• Meeting Point: ${activity.address}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    if (activity.providerPhone != null)
                      pw.Text(
                        '• Contact: ${activity.providerPhone}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
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
      final file = File('${output.path}/activity_voucher_${booking.id.substring(0, 8)}.pdf');
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
          SnackBar(
            content: Text('Error saving voucher: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final booking = widget.booking;
    final activity = widget.activity;

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
                              'Your adventure awaits',
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                'Confirmation #${booking.id.substring(0, 8).toUpperCase()}',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildActivityInfoCard(activity, booking, colors),
                            const SizedBox(height: 16),
                            _buildBookingDetailsCard(activity, booking, colors),
                            const SizedBox(height: 16),
                            if (activity.address.isNotEmpty)
                              _buildMeetingPointCard(activity, colors),
                            const SizedBox(height: 16),
                            _buildPaymentCard(booking, colors),
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
      animation: _checkController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.success, colors.success.withOpacity(0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.success.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Transform.scale(
                scale: _checkAnimation.value,
                child: const Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityInfoCard(
      Activity activity, ActivityBooking booking, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: activity.category.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                activity.imageUrls.isNotEmpty
                    ? Image.network(
                        activity.imageUrls.first,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: activity.category.color.withOpacity(0.2),
                          child: Center(
                            child: Icon(
                              activity.category.icon,
                              size: 60,
                              color: activity.category.color,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 150,
                        color: activity.category.color.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            activity.category.icon,
                            size: 60,
                            color: activity.category.color,
                          ),
                        ),
                      ),
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
                        Icon(activity.category.icon, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          activity.category.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.cityName}, ${activity.countryName}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.rating} (${activity.reviewCount} reviews)',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const Spacer(),
                    Icon(Icons.schedule, size: 16, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      activity.formattedDuration,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard(
      Activity activity, ActivityBooking booking, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_rounded, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Activity Date',
            DateFormat('EEEE, MMM d, yyyy').format(booking.activityDate),
            colors,
          ),
          _buildInfoRow(
            Icons.people_rounded,
            'Participants',
            '${booking.numberOfParticipants} ${booking.numberOfParticipants > 1 ? 'people' : 'person'}',
            colors,
          ),
          _buildInfoRow(
            Icons.schedule_rounded,
            'Duration',
            activity.formattedDuration,
            colors,
          ),
          if (booking.specialRequests != null && booking.specialRequests!.isNotEmpty)
            _buildInfoRow(
              Icons.note_rounded,
              'Special Requests',
              booking.specialRequests!,
              colors,
            ),
        ],
      ),
    );
  }

  Widget _buildMeetingPointCard(Activity activity, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activity.category.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: activity.category.color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activity.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pin_drop_rounded, color: activity.category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meeting Point',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.address,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please arrive 15 minutes before the scheduled time',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: 13,
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

  Widget _buildPaymentCard(ActivityBooking booking, AppColors colors) {
    final activity = widget.activity;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [activity.category.color, activity.category.color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: activity.category.color.withOpacity(0.4),
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
              const Icon(Icons.receipt_long_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Text(
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
          _buildPaymentRow(
            '${activity.formattedPrice} x ${booking.numberOfParticipants}',
            '\$${booking.totalPrice.toStringAsFixed(2)}',
          ),
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
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
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

  Widget _buildInfoRow(IconData icon, String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
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
    final activity = widget.activity;
    final confettiColors = [
      activity.category.color,
      colors.primary,
      colors.primaryLight,
      colors.success,
      Colors.amber,
      Colors.pink,
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
