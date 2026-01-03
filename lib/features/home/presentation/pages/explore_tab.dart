import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../destination/presentation/pages/destination_detail_page.dart';

class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedCategory = 0;

  List<String> _getCategories(AppLocalizations l10n) => [
    l10n.all,
    l10n.beach,
    l10n.mountain,
    l10n.city,
    l10n.adventure,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    return Container(
      decoration: BoxDecoration(
        gradient: colors.backgroundGradient,
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Explore",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Discover amazing destinations",
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSearchBar(colors),
                    const SizedBox(height: 24),
                    _buildCategories(colors),
                  ],
                ),
              ),
              Expanded(
                child: _buildDestinationGrid(colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppColors colors) {
    return Container(
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
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search destinations...",
          hintStyle: TextStyle(color: colors.textHint),
          prefixIcon: Icon(Icons.search_rounded, color: colors.primaryLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCategories(AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [colors.primaryLight, colors.secondary],
                      )
                    : null,
                color: isSelected ? null : colors.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.primaryLight.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? colors.surface : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDestinationGrid(AppColors colors) {
    final destinations = [
      {'name': 'Bali', 'country': 'Indonesia', 'rating': '4.9', 'price': '\$850', 'color': const Color(0xFF06B6D4)},
      {'name': 'Santorini', 'country': 'Greece', 'rating': '4.8', 'price': '\$1,200', 'color': const Color(0xFF3B82F6)},
      {'name': 'Maldives', 'country': 'Asia', 'rating': '5.0', 'price': '\$2,500', 'color': const Color(0xFF8B5CF6)},
      {'name': 'Swiss Alps', 'country': 'Switzerland', 'rating': '4.7', 'price': '\$1,800', 'color': const Color(0xFF10B981)},
      {'name': 'Kyoto', 'country': 'Japan', 'rating': '4.8', 'price': '\$1,100', 'color': const Color(0xFFEC4899)},
      {'name': 'Morocco', 'country': 'Africa', 'rating': '4.6', 'price': '\$750', 'color': const Color(0xFFF59E0B)},
    ];

    return GridView.builder(
      padding: Responsive.padding(context),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridCrossAxisCount(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final dest = destinations[index];
        return _buildGridCard(
          dest['name'] as String,
          dest['country'] as String,
          dest['rating'] as String,
          dest['price'] as String,
          dest['color'] as Color,
          index,
          colors,
        );
      },
    );
  }

  Widget _buildGridCard(
    String name,
    String country,
    String rating,
    String price,
    Color color,
    int index,
    AppColors colors,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DestinationDetailPage(
                name: name,
                country: country,
                accentColor: color,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 50,
                        color: colors.surface.withOpacity(0.8),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_outline_rounded,
                          size: 18,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          country,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: color,
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
      ),
    );
  }
}
