import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/domain/entities/activity.dart';
import 'package:frontend/features/home/presentation/viewmodels/activity_provider.dart';
import 'package:frontend/features/home/presentation/viewmodels/trip_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityDetailPage extends ConsumerStatefulWidget {
  final Activity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  ConsumerState<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends ConsumerState<ActivityDetailPage> {
  final PageController _imageController = PageController();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int _currentImageIndex = 0;
  bool _showBookingForm = false;
  
  // Booking form state
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _participants = 1;
  final TextEditingController _specialRequestsController = TextEditingController();

  @override
  void dispose() {
    _imageController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final activity = widget.activity;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Image Carousel
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: activity.category.color,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
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
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: activity.isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                    onPressed: () {
                      ref.read(activitiesProvider.notifier).toggleFavorite(activity.id);
                    },
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.share, color: Colors.white),
                    ),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageCarousel(activity, colors),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Info Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category & Rating Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: activity.category.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(activity.category.icon, color: activity.category.color, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        activity.category.displayName,
                                        style: TextStyle(
                                          color: activity.category.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${activity.rating.toStringAsFixed(1)} (${activity.reviewCount} reviews)',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Title
                            Text(
                              activity.name,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Location
                            Row(
                              children: [
                                Icon(Icons.location_on, color: colors.primary, size: 18),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    activity.address.isNotEmpty 
                                        ? activity.address 
                                        : '${activity.cityName}, ${activity.countryName}',
                                    style: TextStyle(color: colors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Quick Info Cards
                            _buildQuickInfoRow(activity, colors),
                            const SizedBox(height: 24),

                            // Description
                            Text(
                              'About This Activity',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              activity.description,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Features Section
                      if (activity.features.isNotEmpty)
                        _buildSection(
                          'Features',
                          Icons.check_circle_outline,
                          activity.features,
                          colors,
                          Colors.green,
                        ),

                      // Requirements Section
                      if (activity.requirements.isNotEmpty)
                        _buildSection(
                          'Requirements',
                          Icons.info_outline,
                          activity.requirements,
                          colors,
                          Colors.orange,
                        ),

                      // What's Included
                      if (activity.includedItems.isNotEmpty)
                        _buildSection(
                          "What's Included",
                          Icons.add_circle_outline,
                          activity.includedItems,
                          colors,
                          colors.primary,
                        ),

                      // What's Not Included
                      if (activity.excludedItems.isNotEmpty)
                        _buildSection(
                          "Not Included",
                          Icons.remove_circle_outline,
                          activity.excludedItems,
                          colors,
                          Colors.red,
                        ),

                      // Map Section
                      _buildMapSection(activity, colors),

                      // Provider Info
                      if (activity.providerName != null)
                        _buildProviderSection(activity, colors),

                      // Comments Section
                      _buildCommentsSection(activity, colors),

                      // Booking Form (if shown)
                      if (_showBookingForm)
                        _buildBookingForm(activity, colors),

                      // Bottom padding for the book button
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Book Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'From',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        activity.formattedPrice,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _showBookingForm = !_showBookingForm);
                      if (_showBookingForm) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activity.category.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _showBookingForm ? 'Hide Form' : 'Book Now',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Activity activity, AppColors colors) {
    if (activity.imageUrls.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              activity.category.color,
              activity.category.color.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            activity.category.icon,
            size: 100,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _imageController,
          itemCount: activity.imageUrls.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, index) {
            return Image.network(
              activity.imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: activity.category.color,
                child: Center(
                  child: Icon(
                    activity.category.icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            );
          },
        ),
        // Image indicators
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              activity.imageUrls.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        // Image counter
        Positioned(
          bottom: 40,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${activity.imageUrls.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoRow(Activity activity, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoCard(
            Icons.schedule,
            'Duration',
            activity.formattedDuration,
            colors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickInfoCard(
            Icons.group,
            'Max Group',
            activity.maxParticipants?.toString() ?? 'Flexible',
            colors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickInfoCard(
            Icons.trending_up,
            'Difficulty',
            activity.difficultyLevel ?? 'All levels',
            colors,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String label, String value, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items, AppColors colors, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMapSection(Activity activity, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: colors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withOpacity(0.2)),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(activity.latitude, activity.longitude),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.frontend',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(activity.latitude, activity.longitude),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: activity.category.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: activity.category.color.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          activity.category.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final url = 'https://www.google.com/maps/search/?api=1&query=${activity.latitude},${activity.longitude}';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(Activity activity, AppColors colors) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provider',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      activity.providerName!,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (activity.providerPhone != null || activity.providerEmail != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (activity.providerPhone != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = 'tel:${activity.providerPhone}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary.withOpacity(0.5)),
                      ),
                    ),
                  ),
                if (activity.providerPhone != null && activity.providerEmail != null)
                  const SizedBox(width: 12),
                if (activity.providerEmail != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = 'mailto:${activity.providerEmail}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      icon: const Icon(Icons.email, size: 18),
                      label: const Text('Email'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary.withOpacity(0.5)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsSection(Activity activity, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: colors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Reviews & Comments',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${activity.comments.length}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Add comment field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    hintStyle: TextStyle(color: colors.textHint),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Rating stars
                    ...List.generate(5, (index) => GestureDetector(
                      onTap: () {
                        // Rating selection
                      },
                      child: Icon(
                        Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      ),
                    )),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          final userId = ref.read(currentUserProvider);
                          final comment = ActivityComment(
                            id: DateTime.now().toString(),
                            userId: userId,
                            userName: 'You',
                            comment: _commentController.text,
                            createdAt: DateTime.now(),
                            rating: 5,
                          );
                          ref.read(activitiesProvider.notifier).addComment(activity.id, comment);
                          _commentController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Comment added!'),
                              backgroundColor: colors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Comments list
          if (activity.comments.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: colors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to share your experience!',
                    style: TextStyle(
                      color: colors.textHint,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...activity.comments.map((comment) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colors.primary.withOpacity(0.1),
                        child: Text(
                          comment.userName[0].toUpperCase(),
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.userName,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(comment.createdAt),
                              style: TextStyle(
                                color: colors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (comment.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              comment.rating!.toString(),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    comment.comment,
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildBookingForm(Activity activity, AppColors colors) {
    final totalPrice = activity.price * _participants;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activity.category.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: activity.category.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: activity.category.color),
              const SizedBox(width: 8),
              Text(
                'Book This Activity',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Date Selection
          Text(
            'Select Date',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Participants
          Text(
            'Number of Participants',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _participants > 1
                      ? () => setState(() => _participants--)
                      : null,
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: _participants > 1 ? colors.primary : colors.textHint,
                  ),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '$_participants',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: (activity.maxParticipants == null || _participants < activity.maxParticipants!)
                      ? () => setState(() => _participants++)
                      : null,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: (activity.maxParticipants == null || _participants < activity.maxParticipants!)
                        ? colors.primary
                        : colors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Special Requests
          Text(
            'Special Requests (Optional)',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _specialRequestsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any dietary requirements, accessibility needs...',
              hintStyle: TextStyle(color: colors.textHint),
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary.withOpacity(0.2)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Price Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activity.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${activity.formattedPrice} x $_participants',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: activity.category.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Confirm Booking Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final userId = ref.read(currentUserProvider);
                final booking = await ref.read(activityBookingsProvider.notifier).bookActivity(
                  activityId: activity.id,
                  userId: userId,
                  activityDate: _selectedDate,
                  numberOfParticipants: _participants,
                  totalPrice: totalPrice,
                  specialRequests: _specialRequestsController.text.isNotEmpty
                      ? _specialRequestsController.text
                      : null,
                );

                if (booking != null && mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: colors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.success.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: colors.success),
                          ),
                          const SizedBox(width: 12),
                          const Text('Booking Confirmed!'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your booking for ${activity.name} has been confirmed.'),
                          const SizedBox(height: 12),
                          Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                          Text('Participants: $_participants'),
                          Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.success,
                          ),
                          child: const Text('Done', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: activity.category.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
