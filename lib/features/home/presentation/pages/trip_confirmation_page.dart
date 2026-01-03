import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/domain/entities/trip.dart';

class TripConfirmationPage extends ConsumerStatefulWidget {
  final Trip trip;
  final bool isUpdate;

  const TripConfirmationPage({
    super.key,
    required this.trip,
    this.isUpdate = false,
  });

  @override
  ConsumerState<TripConfirmationPage> createState() => _TripConfirmationPageState();
}

class _TripConfirmationPageState extends ConsumerState<TripConfirmationPage>
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

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final trip = widget.trip;

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
                              widget.isUpdate ? 'Trip Updated!' : 'Trip Saved!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isUpdate
                                  ? 'Your trip has been successfully updated'
                                  : 'Your adventure awaits!',
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildTripCard(trip, colors),
                            const SizedBox(height: 24),
                            _buildTripDetails(trip, colors),
                            const SizedBox(height: 24),
                            _buildTaskProgress(trip, colors),
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

  Widget _buildTripCard(Trip trip, AppColors colors) {
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
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [trip.color, trip.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  trip.icon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destination,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: colors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.cityName != null
                                ? '${trip.cityName}, ${trip.countryName}'
                                : trip.countryName ?? trip.destination,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
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
                      'Trip ID',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      trip.id.length > 12 ? trip.id.substring(0, 12).toUpperCase() : trip.id.toUpperCase(),
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
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

  Widget _buildTripDetails(Trip trip, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.textHint.withOpacity(0.05),
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
              Icon(Icons.info_outline_rounded, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Trip Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_rounded, 'Status: ${trip.date}', colors),
          _buildInfoRow(Icons.schedule_rounded, 'Duration: ${trip.days}', colors),
          if (trip.latitude != null && trip.longitude != null)
            _buildInfoRow(
              Icons.explore_rounded,
              'Coordinates: ${trip.latitude!.toStringAsFixed(2)}°, ${trip.longitude!.toStringAsFixed(2)}°',
              colors,
            ),
        ],
      ),
    );
  }

  Widget _buildTaskProgress(Trip trip, AppColors colors) {
    final completedTasks = trip.taskStatus.values.where((v) => v).length;
    final totalTasks = trip.taskStatus.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.success, colors.success.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.success.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.task_alt_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Planning Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completedTasks/$totalTasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trip.taskStatus.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: entry.value ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: entry.value ? colors.success : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: entry.value ? colors.success : Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
          onTap: () {
            Navigator.pop(context, true);
          },
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
                Icon(Icons.check_circle_rounded, color: colors.surface),
                const SizedBox(width: 10),
                Text(
                  'Continue Planning',
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
                  Navigator.pop(context);
                  Navigator.pop(context);
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
                      Icon(Icons.home_rounded, color: colors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Go Home',
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
