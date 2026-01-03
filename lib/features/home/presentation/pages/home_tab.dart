import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../planner/presentation/pages/ai_planner_page.dart';
import '../../../destination/presentation/pages/destination_detail_page.dart';
import '../../../booking/presentation/pages/flights_page.dart';
import '../../../booking/presentation/pages/hotels_page.dart';
import '../../../booking/presentation/pages/cars_page.dart';
import '../../../booking/presentation/pages/food_page.dart';
import 'package:frontend/features/home/presentation/viewmodels/notification_provider.dart';
import 'package:frontend/features/home/presentation/viewmodels/trip_provider.dart';

import 'notifications_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    
    // Load trips from database on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tripProvider.notifier).loadTrips(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final colors = ref.watch(appColorsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: colors.backgroundGradient,
        ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    maxWidth: 1200,
                    padding: Responsive.padding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(authState, l10n, colors),
                        const SizedBox(height: 24),
                        _buildSearchBar(l10n, colors),
                        const SizedBox(height: 32),
                        _buildResponsiveQuickActions(context, l10n, colors),
                        const SizedBox(height: 32),
                        _buildResponsiveFeaturedSection(context, l10n, colors),
                        const SizedBox(height: 24),
                        _buildAIPlannerCard(l10n, colors),
                        const SizedBox(height: 32),
                        _buildResponsivePopularDestinations(context, l10n, colors),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(authState, AppLocalizations l10n, AppColors colors) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcomeBack,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              authState.user?.name ?? l10n.traveler,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => _openNotifications(),
              child: _buildIconButton(Icons.notifications_outlined, colors, badge: unreadCount > 0 ? unreadCount : null),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showProfileMenu(),
              child: _buildAvatar(authState, colors),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, AppColors colors, {int? badge}) {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primaryLight.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: colors.primary),
        ),
        if (badge != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badge',
                style: TextStyle(
                  color: colors.surface,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(authState, AppColors colors) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: colors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: colors.primaryLight.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          (authState.user?.name ?? "U")[0].toUpperCase(),
          style: TextStyle(
            color: colors.surface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, AppColors colors) {
    return GestureDetector(
      onTap: () => _openSearch(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: colors.searchBarBorder != Colors.transparent
              ? Border.all(color: colors.searchBarBorder, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: colors.primaryLight.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              hintStyle: TextStyle(color: colors.textHint),
              prefixIcon: Icon(Icons.search_rounded, color: colors.primaryLight),
              suffixIcon: Icon(Icons.tune_rounded, color: colors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildQuickActionItem(IconData icon, String label, Color color, AppColors colors) {
    return GestureDetector(
      onTap: () => _onQuickActionTap(label),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQuickActionTap(String label) {
    Widget page;
    switch (label) {
      case 'Flights':
        page = const FlightsPage();
        break;
      case 'Hotels':
        page = const HotelsPage();
        break;
      case 'Cars':
        page = const CarsPage();
        break;
      case 'Food':
        page = const FoodPage();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  void _showProfileMenu() {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authNotifierProvider);
    final colors = ref.read(appColorsProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundColor: colors.primary,
              child: Text(
                (authState.user?.name ?? "U")[0].toUpperCase(),
                style: TextStyle(
                  color: colors.surface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authState.user?.name ?? l10n.traveler,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            Text(
              authState.user?.email ?? "user@example.com",
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline, color: colors.primary),
              ),
              title: Text(l10n.viewProfile),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings_outlined, color: colors.info),
              ),
              title: Text(l10n.settings),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.logout, color: colors.error),
              ),
              title: Text(l10n.signOut, style: TextStyle(color: colors.error)),
              onTap: () {
                Navigator.pop(context);
                ref.read(tripProvider.notifier).clearTrips();
                ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(String city, String country, String rating, Color accentColor, AppColors colors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DestinationDetailPage(
              name: city,
              country: country,
              accentColor: accentColor,
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.8),
                  accentColor.withOpacity(0.5),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 50,
                    color: colors.surface.withOpacity(0.9),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: colors.warning),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: colors.textPrimary,
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
                  city,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: colors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      country,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textHint,
                      ),
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

  Widget _buildAIPlannerCard(AppLocalizations l10n, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.accent],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: colors.surface),
                      const SizedBox(width: 6),
                      Text(
                        l10n.aiPowered,
                        style: TextStyle(
                          color: colors.surface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.smartTripPlanner,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.surface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.createPerfectItinerary,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.surface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AIPlannerPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.planNow,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 40,
              color: colors.surface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularItem(String title, String subtitle, IconData icon, AppColors colors) {
    final parts = title.split(', ');
    final name = parts[0];
    final country = parts.length > 1 ? parts[1] : '';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DestinationDetailPage(
              name: name,
              country: country,
              accentColor: colors.primary,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.primaryLight.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primaryLight.withOpacity(0.2),
                    colors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: colors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: colors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveQuickActions(BuildContext context, AppLocalizations l10n, AppColors colors) {
    final actions = [
      {'icon': Icons.flight_rounded, 'label': l10n.flights, 'color': colors.primary},
      {'icon': Icons.hotel_rounded, 'label': l10n.hotels, 'color': const Color(0xFF06B6D4)},
      {'icon': Icons.directions_car_rounded, 'label': l10n.cars, 'color': colors.warning},
      {'icon': Icons.restaurant_rounded, 'label': l10n.food, 'color': colors.error},
    ];

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        isDesktop || isTablet
            ? Row(
                children: actions.map((action) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildQuickActionItem(
                        action['icon'] as IconData,
                        action['label'] as String,
                        action['color'] as Color,
                        colors,
                      ),
                    ),
                  );
                }).toList(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions.map((action) {
                  return _buildQuickActionItem(
                    action['icon'] as IconData,
                    action['label'] as String,
                    action['color'] as Color,
                    colors,
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildResponsiveFeaturedSection(BuildContext context, AppLocalizations l10n, AppColors colors) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final destinations = [
      {"city": "Paris", "country": "France", "rating": "4.9", "color": colors.featuredPink},
      {"city": "Tokyo", "country": "Japan", "rating": "4.8", "color": colors.featuredPurple},
      {"city": "New York", "country": "USA", "rating": "4.7", "color": colors.featuredBlue},
      {"city": "Dubai", "country": "UAE", "rating": "4.9", "color": colors.featuredOrange},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.featuredDestinations,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _openSearch(),
              child: Text(
                l10n.seeAll,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        isDesktop || isTablet
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 4 : 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final dest = destinations[index];
                  return _buildDestinationCard(
                    dest["city"] as String,
                    dest["country"] as String,
                    dest["rating"] as String,
                    dest["color"] as Color,
                    colors,
                  );
                },
              )
            : SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final dest = destinations[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < destinations.length - 1 ? 16 : 0),
                      child: SizedBox(
                        width: 170,
                        child: _buildDestinationCard(
                          dest["city"] as String,
                          dest["country"] as String,
                          dest["rating"] as String,
                          dest["color"] as Color,
                          colors,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildResponsivePopularDestinations(BuildContext context, AppLocalizations l10n, AppColors colors) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final destinations = [
      {"title": "Bali, Indonesia", "subtitle": "1,234 ${l10n.trips}", "icon": Icons.beach_access_rounded},
      {"title": "Santorini, Greece", "subtitle": "987 ${l10n.trips}", "icon": Icons.sailing_rounded},
      {"title": "Maldives", "subtitle": "876 ${l10n.trips}", "icon": Icons.water_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.popularThisMonth,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        isDesktop || isTablet
            ? Row(
                children: destinations.map((dest) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildPopularItem(
                        dest["title"] as String,
                        dest["subtitle"] as String,
                        dest["icon"] as IconData,
                        colors,
                      ),
                    ),
                  );
                }).toList(),
              )
            : Column(
                children: destinations.map((dest) {
                  return _buildPopularItem(
                    dest["title"] as String,
                    dest["subtitle"] as String,
                    dest["icon"] as IconData,
                    colors,
                  );
                }).toList(),
              ),
      ],
    );
  }
}
