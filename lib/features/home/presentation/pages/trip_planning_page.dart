import 'dart:convert';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/presentation/pages/budget_page.dart';
import 'package:frontend/features/home/presentation/pages/transportation_page.dart';
import 'package:frontend/features/booking/presentation/pages/hotels_page.dart';
import 'package:frontend/features/home/presentation/pages/activities_page.dart';
import 'package:frontend/features/home/presentation/pages/notifications_page.dart';
import 'package:frontend/features/home/presentation/pages/trip_confirmation_page.dart';
import 'package:frontend/features/home/presentation/pages/full_trip_plan_page.dart';
import 'package:frontend/features/home/domain/entities/trip.dart';
import 'package:frontend/features/home/presentation/viewmodels/trip_provider.dart';
import 'package:frontend/features/home/presentation/viewmodels/notification_provider.dart';
import 'package:frontend/services/unsplash_service.dart';
import 'package:http/http.dart' as http;

class TripPlanningPage extends ConsumerStatefulWidget {
  final String? cityName;
  final String countryName;
  final String? tripId;
  final String? destinationName;
  final double? latitude;
  final double? longitude;
  final Color? tripColor;
  final bool? isCountryOnly;

  const TripPlanningPage({
    super.key,
    required this.cityName,
    required this.countryName,
    this.tripId,
    this.destinationName,
    this.latitude,
    this.longitude,
    this.tripColor,
    this.isCountryOnly,
  });

  @override
  ConsumerState<TripPlanningPage> createState() => _TripPlanningPageState();
}

class _TripPlanningPageState extends ConsumerState<TripPlanningPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _imageUrls = [];
  bool _isLoadingImages = true;
  bool _isLoadingLocationInfo = true;
  
  String? _correctedCityName;
  String? _correctedCountryName;
  String? _locationDescription;
  bool _isCountryOnly = false;
  
  bool _isSaved = false;
  String? _currentTripId;
  
  Map<String, bool> _taskStatus = {
    'Transportation': false,
    'Hotels': false,
    'Activities': false,
    'Budget': false,
  };

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.tripId != null;
    _currentTripId = widget.tripId;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _fetchLocationInfo();
    _fetchImages();
    _animationController.forward();
    
    Future.delayed(const Duration(seconds: 3), _autoScrollImages);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentTripId != null) {
      final trips = ref.read(tripProvider);
      try {
        final trip = trips.firstWhere((t) => t.id == _currentTripId);
        if (trip.taskStatus.isNotEmpty) {
           setState(() {
             _taskStatus = Map<String, bool>.from(trip.taskStatus);
           });
        }
      } catch (_) {}
    }
  }

  bool get _allTasksCompleted => _taskStatus.values.every((v) => v);
  
  Future<bool> _onWillPop() async {
    final colors = ref.read(appColorsProvider);
    
    if (_isSaved) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Save Changes?',
            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Do you want to save your changes before leaving?',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Discard', style: TextStyle(color: colors.error)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (shouldSave == null) return false;
      if (shouldSave) _saveTrip();
      return true;
    } else {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Save Trip?',
            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'You have an unsaved trip. Do you want to save it before leaving?',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Discard', style: TextStyle(color: colors.error)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (shouldSave == null) return false;
      if (shouldSave) _saveTrip();
      return true;
    }
  }

  Future<void> _fetchLocationInfo() async {
    try {
      final bool isCountrySelection = widget.cityName == null || 
          widget.cityName!.isEmpty || 
          widget.cityName == "No city selected";
      
      final searchTerm = isCountrySelection ? widget.countryName : widget.cityName!;
      
      final wikipediaUrl = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts|pageimages&exintro=&explaintext=&redirects=1&titles=${Uri.encodeComponent(searchTerm)}&origin=*'
      );
      
      final response = await http.get(wikipediaUrl);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;
        
        if (pages.isNotEmpty) {
          final pageData = pages.values.first;
          final title = pageData['title'] as String?;
          final extract = pageData['extract'] as String?;
          
          if (title != null && extract != null) {
            setState(() {
              _isCountryOnly = isCountrySelection;
              
              if (_isCountryOnly) {
                _correctedCountryName = widget.countryName;
                _correctedCityName = null;
              } else {
                _correctedCityName = widget.cityName;
                _correctedCountryName = widget.countryName;
              }
              
              _locationDescription = _getShortDescription(extract);
              _isLoadingLocationInfo = false;
            });
          } else {
            _setDefaultValues(isCountrySelection);
          }
        } else {
          _setDefaultValues(isCountrySelection);
        }
      } else {
        _setDefaultValues(isCountrySelection);
      }
    } catch (e) {
      debugPrint('Error fetching location info: $e');
      _setDefaultValues(widget.cityName == null || widget.cityName!.isEmpty);
    }
  }

  void _setDefaultValues(bool isCountrySelection) {
    if (!mounted) return;
    setState(() {
      _isCountryOnly = isCountrySelection;
      if (_isCountryOnly) {
        _correctedCountryName = widget.countryName;
        _correctedCityName = null;
      } else {
        _correctedCityName = widget.cityName;
        _correctedCountryName = widget.countryName;
      }
      _locationDescription = null;
      _isLoadingLocationInfo = false;
    });
  }

  String _getShortDescription(String text) {
    final sentences = text.split(RegExp(r'\.(?:\s|$)'));
    final shortDesc = sentences.take(2).join('. ');
    return shortDesc.length > 200 ? '${shortDesc.substring(0, 200)}...' : '$shortDesc.';
  }

  void _autoScrollImages() {
    if (mounted && _pageController.hasClients && _imageUrls.isNotEmpty) {
      final nextPage = (_pageController.page?.toInt() ?? 0) + 1;
      _pageController.animateToPage(
        nextPage % _imageUrls.length,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ).then((_) => Future.delayed(const Duration(seconds: 5), _autoScrollImages));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    try {
      final cityQuery = widget.cityName ?? widget.countryName;
      final searchQuery = "$cityQuery ${widget.countryName} travel landmarks";

      final urls = await UnsplashService.searchImages(
        query: searchQuery,
        perPage: 6,
      );

      if (mounted) {
        setState(() {
          _imageUrls = urls.isNotEmpty
              ? urls
              : ['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080'];
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageUrls = [
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1080',
            'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=1080',
          ];
          _isLoadingImages = false;
        });
      }
    }
  }

  void _onTaskTap(String task) async {
    if (_isCountryOnly || _correctedCityName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a city first to start planning!'),
          backgroundColor: ref.read(appColorsProvider).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Widget page;
    switch (task) {
      case 'Transportation':
        page = const TransportationPage();
        break;
      case 'Hotels':
        page = HotelsPage(city: _correctedCityName, country: _correctedCountryName);
        break;
      case 'Activities':
        page = ActivitiesPage(
          cityName: _correctedCityName,
          countryName: _correctedCountryName,
          latitude: widget.latitude,
          longitude: widget.longitude,
        );
        break;
      case 'Budget':
        page = const BudgetPage();
        break;
      default:
        return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (result == true) {
      setState(() {
        _taskStatus[task] = true;
      });
      _updateTripTaskStatus();
    }
  }

  void _updateTripTaskStatus() {
    final allCompleted = _taskStatus.values.every((v) => v);
    
    if (_currentTripId != null || _isSaved) {
      final user = ref.read(currentUserProvider);
      final colors = ref.read(appColorsProvider);
      final tripColor = widget.tripColor ?? colors.primary;
      
      final updatedTrip = Trip(
        id: _currentTripId ?? widget.tripId!,
        userId: user,
        destination: widget.destinationName ?? _correctedCityName ?? widget.countryName,
        date: 'Planned',
        days: 'TBD',
        color: tripColor,
        icon: (widget.isCountryOnly ?? _isCountryOnly) ? Icons.public_rounded : Icons.flight_takeoff_rounded,
        cityName: _correctedCityName,
        countryName: _correctedCountryName ?? widget.countryName,
        latitude: widget.latitude,
        longitude: widget.longitude,
        taskStatus: Map<String, bool>.from(_taskStatus),
      );
      
      ref.read(tripProvider.notifier).updateTrip(updatedTrip);
      
      if (allCompleted) {
        _addTripCompletedNotification();
      }
    }
  }
  
  void _addTripCompletedNotification() {
    final destination = _correctedCityName ?? widget.countryName;
    ref.read(notificationProvider.notifier).addNotification(
      NotificationItem(
        icon: Icons.check_circle_rounded,
        type: NotificationType.success,
        title: 'Trip Fully Planned! 🎉',
        description: 'Your trip to $destination is now fully planned. All tasks are completed!',
        time: 'Just now',
        isUnread: true,
      ),
    );
  }

  Future<void> _saveTrip() async {
    if (_isCountryOnly || _correctedCityName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a city first!'),
          backgroundColor: ref.read(appColorsProvider).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final tripId = _currentTripId ?? 'trip_${DateTime.now().millisecondsSinceEpoch}';
    final user = ref.read(currentUserProvider);
    final colors = ref.read(appColorsProvider);
    final tripColor = widget.tripColor ?? colors.primary;
    
    final newTrip = Trip(
      id: tripId,
      userId: user,
      destination: widget.destinationName ?? _correctedCityName ?? widget.countryName,
      date: 'Planned',
      days: 'TBD',
      color: tripColor,
      icon: (widget.isCountryOnly ?? _isCountryOnly) ? Icons.public_rounded : Icons.flight_takeoff_rounded,
      cityName: _correctedCityName,
      countryName: _correctedCountryName ?? widget.countryName,
      latitude: widget.latitude,
      longitude: widget.longitude,
      taskStatus: Map<String, bool>.from(_taskStatus),
    );
    
    if (_isSaved && _currentTripId != null) {
      final savedTrip = await ref.read(tripProvider.notifier).updateTrip(newTrip);
      if (savedTrip != null && mounted) {
        _showConfirmationPage(savedTrip, isUpdate: true);
      }
    } else {
      final savedTrip = await ref.read(tripProvider.notifier).addTrip(newTrip);
      if (savedTrip != null && mounted) {
        setState(() {
          _isSaved = true;
          _currentTripId = savedTrip.id;
        });
        _showConfirmationPage(savedTrip, isUpdate: false);
      }
    }
  }

  void _showConfirmationPage(Trip trip, {required bool isUpdate}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripConfirmationPage(
          trip: trip,
          isUpdate: isUpdate,
        ),
      ),
    );
  }

  void _openFullPlan() {
    if (!_isSaved || _currentTripId == null) {
      _saveTrip();
    }
    
    final user = ref.read(currentUserProvider);
    final colors = ref.read(appColorsProvider);
    final tripColor = widget.tripColor ?? colors.primary;
    
    final trip = Trip(
      id: _currentTripId ?? 'trip_${DateTime.now().millisecondsSinceEpoch}',
      userId: user,
      destination: widget.destinationName ?? _correctedCityName ?? widget.countryName,
      date: 'Planned',
      days: 'TBD',
      color: tripColor,
      icon: Icons.flight_takeoff_rounded,
      cityName: _correctedCityName,
      countryName: _correctedCountryName ?? widget.countryName,
      latitude: widget.latitude,
      longitude: widget.longitude,
      taskStatus: Map<String, bool>.from(_taskStatus),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullTripPlanPage(trip: trip, imageUrls: _imageUrls),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final themeColor = widget.tripColor ?? colors.primary;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            // Full-screen image carousel with gradient overlay
            Positioned.fill(
              child: Stack(
                children: [
                  // Image Carousel
                  _isLoadingImages
                      ? Container(
                          color: colors.surfaceVariant,
                          child: Center(child: CircularProgressIndicator(color: themeColor)),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _imageUrls.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              key: ValueKey(_imageUrls[index]),
                              tween: Tween(begin: 1.0, end: 1.15),
                              duration: const Duration(seconds: 15),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Image.network(
                                    _imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: colors.surfaceVariant,
                                      child: Icon(Icons.broken_image, color: colors.textHint),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  
                  // Animated Gradient Overlay with theme color
                  AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              themeColor.withOpacity(0.3 + 0.1 * _gradientController.value),
                              themeColor.withOpacity(0.7),
                              themeColor.withOpacity(0.95),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(colors),
                  
                  // Header with Location Info
                  Expanded(
                    flex: 2,
                    child: _buildLocationHeader(colors, themeColor),
                  ),
                  
                  // Main Content Card
                  Expanded(
                    flex: 3,
                    child: _buildMainContentCard(colors, themeColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          Row(
            children: [
              _buildGlassButton(
                icon: Icons.notifications_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildGlassButton(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader(AppColors colors, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Country Name with futuristic styling
          _isLoadingLocationInfo
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated accent line
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 40 + 20 * _pulseController.value,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.white.withOpacity(0.3)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5 * _pulseController.value),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Country Name
                    Text(
                      (_correctedCountryName ?? widget.countryName).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(offset: const Offset(0, 4), blurRadius: 20, color: Colors.black54),
                          Shadow(offset: const Offset(0, 0), blurRadius: 40, color: themeColor.withOpacity(0.5)),
                        ],
                      ),
                    ),
                    
                    // City Name with icon
                    if (!_isCountryOnly && _correctedCityName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.location_city_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _correctedCityName!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Warning for country only
                    if (_isCountryOnly)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.warning),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: colors.warning, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Select a city to start planning",
                              style: TextStyle(color: colors.warning, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
          
          const SizedBox(height: 24),
          
          // Page Indicator
          if (!_isLoadingImages && _imageUrls.length > 1)
            Row(
              children: List.generate(
                _imageUrls.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMainContentCard(AppColors colors, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textHint.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Description Card (moved here)
              if (_locationDescription != null && !_isCountryOnly)
                _buildDescriptionCard(colors, themeColor),
              
              const SizedBox(height: 24),
              
              // Trip Configuration Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trip Configuration",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isCountryOnly 
                            ? "Select a city first" 
                            : _allTasksCompleted 
                                ? "All set! Ready to go" 
                                : "4 steps to ready",
                        style: TextStyle(
                          fontSize: 13,
                          color: _isCountryOnly 
                              ? colors.warning 
                              : _allTasksCompleted 
                                  ? colors.success 
                                  : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  _buildProgressIndicator(colors, themeColor),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Timeline with Tasks
              _buildTimelineTask(0, "Transportation", Icons.flight_takeoff_rounded, "Flights, Train, Car", colors, themeColor, _taskStatus['Transportation'] ?? false),
              _buildTimelineTask(1, "Hotels", Icons.hotel_rounded, "Stay & Accommodation", colors, themeColor, _taskStatus['Hotels'] ?? false),
              _buildTimelineTask(2, "Activities", Icons.local_activity_rounded, "Tours & Attractions", colors, themeColor, _taskStatus['Activities'] ?? false),
              _buildTimelineTask(3, "Budget", Icons.attach_money_rounded, "Expenses & Planning", colors, themeColor, _taskStatus['Budget'] ?? false, isLast: true),
              
              const SizedBox(height: 32),
              
              // Action Button
              _buildActionButton(colors, themeColor),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(AppColors colors, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withOpacity(0.1),
            themeColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_outline_rounded, color: themeColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                "About this destination",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _locationDescription!,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AppColors colors, Color themeColor) {
    final progress = _taskStatus.values.where((e) => e).length / 4;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                backgroundColor: colors.surfaceVariant,
                color: _allTasksCompleted ? colors.success : themeColor,
                strokeWidth: 5,
              );
            },
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: _allTasksCompleted
              ? Icon(Icons.check, color: colors.success, size: 24, key: const ValueKey('check'))
              : Text(
                  "${(progress * 100).toInt()}%",
                  key: ValueKey<int>((progress * 100).toInt()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTimelineTask(int index, String title, IconData icon, String subtitle, AppColors colors, Color themeColor, bool isCompleted, {bool isLast = false}) {
    final isDisabled = _isCountryOnly;
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-0.5, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1 * index, 0.5 + (0.1 * index), curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.1 * index, 0.5 + (0.1 * index), curve: Curves.easeOut),
        )),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Column (Dot + Line)
              Column(
                children: [
                  // Dot with glow effect
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCompleted 
                          ? LinearGradient(colors: [colors.success, colors.success.withOpacity(0.8)])
                          : null,
                      color: isCompleted ? null : (isDisabled ? colors.surfaceVariant : colors.surface),
                      border: Border.all(
                        color: isCompleted ? colors.success : (isDisabled ? colors.textHint.withOpacity(0.3) : themeColor.withOpacity(0.5)),
                        width: 3,
                      ),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: colors.success.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isCompleted
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : (isDisabled ? Center(
                            child: Icon(
                              Icons.lock,
                              size: 12,
                              color: colors.textHint,
                            ),
                          ) : null),
                  ),
                  // Connecting Line with gradient
                  if (!isLast)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isCompleted ? colors.success : (isDisabled ? colors.textHint.withOpacity(0.3) : themeColor.withOpacity(0.4)),
                              _taskStatus.values.toList()[index + 1] 
                                  ? colors.success 
                                  : (isDisabled ? colors.textHint.withOpacity(0.1) : themeColor.withOpacity(0.15)),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 18),
              // Task Card
              Expanded(
                child: Opacity(
                  opacity: isDisabled ? 0.5 : 1.0,
                  child: GestureDetector(
                    onTap: () => _onTaskTap(title),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: isCompleted 
                            ? LinearGradient(
                                colors: [colors.success.withOpacity(0.15), colors.success.withOpacity(0.05)],
                              )
                            : null,
                        color: isCompleted ? null : (isDisabled ? colors.surfaceVariant : colors.surface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCompleted 
                              ? colors.success.withOpacity(0.4) 
                              : (isDisabled ? colors.textHint.withOpacity(0.2) : themeColor.withOpacity(0.15)),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCompleted 
                                ? colors.success.withOpacity(0.15) 
                                : colors.textHint.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: isCompleted
                                  ? LinearGradient(colors: [colors.success, colors.success.withOpacity(0.7)])
                                  : null,
                              color: isCompleted 
                                  ? null 
                                  : (isDisabled ? colors.textHint.withOpacity(0.1) : themeColor.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              icon,
                              color: isCompleted ? Colors.white : (isDisabled ? colors.textHint : themeColor),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDisabled ? colors.textHint : colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDisabled ? colors.textHint.withOpacity(0.7) : colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isCompleted ? Icons.check_circle : (isDisabled ? Icons.lock_outline : Icons.arrow_forward_ios_rounded),
                            size: isCompleted ? 26 : 18,
                            color: isCompleted 
                                ? colors.success 
                                : (isDisabled ? colors.textHint : colors.textHint.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(AppColors colors, Color themeColor) {
    final isDisabled = _isCountryOnly;
    
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
        ),
        child: GestureDetector(
          onTap: isDisabled 
              ? null 
              : (_allTasksCompleted ? _openFullPlan : _saveTrip),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : LinearGradient(
                      colors: _allTasksCompleted
                          ? [colors.success, colors.success.withOpacity(0.8)]
                          : [themeColor, themeColor.withOpacity(0.8)],
                    ),
              color: isDisabled ? colors.textHint.withOpacity(0.3) : null,
              borderRadius: BorderRadius.circular(30),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: (_allTasksCompleted ? colors.success : themeColor).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDisabled 
                      ? Icons.lock_outline 
                      : (_allTasksCompleted 
                          ? Icons.explore_rounded 
                          : (widget.tripId != null ? Icons.update_rounded : Icons.bookmark_add_rounded)),
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  isDisabled 
                      ? "SELECT A CITY" 
                      : (_allTasksCompleted 
                          ? "SEE FULL PLAN" 
                          : (widget.tripId != null ? "UPDATE TRIP" : "SAVE TRIP")),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
