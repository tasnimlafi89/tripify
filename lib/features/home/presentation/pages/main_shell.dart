import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:frontend/features/auth/presentation/pages/sign_in_page.dart';
import 'package:frontend/features/auth/presentation/viewmodels/auth_state.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:frontend/core/theme/theme.dart';
import '../../../../core/utils/responsive.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../viewmodels/trip_provider.dart';

import 'home_tab.dart';
import 'explore_tab.dart';
import 'trips_tab.dart';
import 'profile_tab.dart';
import 'add_trip_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    ExploreTab(),
    HomePageTripsSection(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);

    // Optional auth redirect
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
        );
      }
    });

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    return Scaffold(
      extendBody: true,
      body: Row(
        children: [
          if (isDesktop || isTablet) _buildSideNav(isDesktop, colors),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: _pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),

      // ✅ CURVED NAV BAR (MOBILE ONLY)
      bottomNavigationBar: (isDesktop || isTablet)
          ? null
          : CurvedNavigationBar(
              index: _currentIndex < 2 ? _currentIndex : _currentIndex + 1,
              height: 70,
              backgroundColor: Colors.transparent,
              color: colors.surface,
              buttonBackgroundColor: colors.primary,
              onTap: (index) {
                if (index == 2) {
                  _openAddTripPage();
                  return;
                }

                setState(() {
                  _currentIndex = index > 2 ? index - 1 : index;
                });
              },
              items: const [
                Icon(Icons.home_rounded, size: 30),
                Icon(Icons.explore_rounded, size: 30),
                Icon(Icons.add_rounded, size: 36),
                Icon(Icons.luggage_rounded, size: 30),
                Icon(Icons.person_rounded, size: 30),
              ],
            ),
    );
  }

  // ================= SIDE NAV (DESKTOP/TABLET) =================

  Widget _buildSideNav(bool isExpanded, AppColors colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 240 : 80,
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.primaryLight.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildLogo(isExpanded, colors),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildSideNavItem(context, 0, Icons.home_rounded, colors),
                  _buildSideNavItem(context, 1, Icons.explore_rounded, colors),
                  _buildSideNavItem(context, 2, Icons.luggage_rounded, colors),
                  _buildSideNavItem(context, 3, Icons.person_rounded, colors),
                ],
              ),
            ),
            _buildLogoutItem(context, colors),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isExpanded, AppColors colors) {
    return Row(
      mainAxisAlignment:
          isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(left: isExpanded ? 12 : 0),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primaryLight, colors.secondary],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Image.asset("assets/travelPlannerLogo.png"),
        ),
        if (isExpanded) ...[
          const SizedBox(width: 14),
          Text(
            "Tripify",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSideNavItem(
    BuildContext context,
    int index,
    IconData icon,
    AppColors colors,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSelected
              ? LinearGradient(
                  colors: [colors.primaryLight, colors.secondary],
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.surface : colors.textHint,
            ),
            const SizedBox(width: 14),
            Text(
              _getNavLabel(context, index),
              style: TextStyle(
                color: isSelected
                    ? colors.surface
                    : colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context, AppColors colors) {
    return GestureDetector(
      onTap: () {
        ref.read(tripProvider.notifier).clearTrips();
        ref.read(authNotifierProvider.notifier).signOut();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 14),
            Text("Sign out", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  String _getNavLabel(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return l10n.home;
      case 1:
        return l10n.explore;
      case 2:
        return l10n.myTrips;
      case 3:
        return l10n.profile;
      default:
        return '';
    }
  }

  void _openAddTripPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTripPage()),
    );
  }
}
