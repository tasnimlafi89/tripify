import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../viewmodels/trip_provider.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveCenter(
              maxWidth: 800,
              padding: Responsive.padding(context),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(authState, l10n, colors),
                  const SizedBox(height: 32),
                  _buildStats(l10n, colors),
                  const SizedBox(height: 32),
                  _buildMenuSection(l10n, colors),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(authState, AppLocalizations l10n, AppColors colors) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.primaryLight, colors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryLight.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (authState.user?.name ?? "U")[0].toUpperCase(),
                  style: TextStyle(
                    color: colors.surface,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          authState.user?.name ?? l10n.traveler,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          authState.user?.email ?? "user@example.com",
          style: TextStyle(
            fontSize: 15,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primaryLight.withOpacity(0.2),
                colors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.premiumTraveler,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(AppLocalizations l10n, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.primaryLight.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("12", l10n.tripsCount, Icons.flight_rounded, colors),
            _buildDivider(),
            _buildStatItem("8", l10n.countries, Icons.public_rounded, colors),
            _buildDivider(),
            _buildStatItem("156", l10n.photos, Icons.photo_library_rounded, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, AppColors colors) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primaryLight.withOpacity(0.2),
                colors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: colors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 60,
      color: const Color(0xFFE5E7EB),
    );
  }

  Widget _buildMenuSection(AppLocalizations l10n, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            Icons.person_outline_rounded,
            l10n.editProfile,
            colors.primary,
            colors,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
          _buildMenuItem(
            Icons.notifications_outlined,
            l10n.notifications,
            const Color(0xFF06B6D4),
            colors,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
          ),
          _buildMenuItem(
            Icons.lock_outline_rounded,
            l10n.privacySecurity,
            const Color(0xFF10B981),
            colors,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          _buildMenuItem(
            Icons.credit_card_rounded,
            l10n.paymentMethods,
            const Color(0xFFF59E0B),
            colors,
            onTap: () => _showComingSoonSnackbar(l10n.paymentMethods, l10n, colors),
          ),
          _buildMenuItem(
            Icons.help_outline_rounded,
            l10n.helpSupport,
            const Color(0xFF3B82F6),
            colors,
            onTap: () => _showComingSoonSnackbar(l10n.helpSupport, l10n, colors),
          ),
          const SizedBox(height: 16),
          _buildLogoutButton(l10n, colors),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, AppColors colors, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: colors.textHint,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonSnackbar(String feature, AppLocalizations l10n, AppColors colors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureComingSoon(feature)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: colors.primary,
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n, AppColors colors) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.error, colors.error.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.error.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog(l10n, colors);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: Icon(Icons.logout_rounded, color: colors.surface),
        label: Text(
          l10n.signOut,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.surface,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(AppLocalizations l10n, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          l10n.signOut,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(tripProvider.notifier).clearTrips();
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.signOut,
              style: TextStyle(color: colors.surface),
            ),
          ),
        ],
      ),
    );
  }
}
