import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n?.settings ?? 'Settings',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n?.account ?? 'ACCOUNT', colors),
            const SizedBox(height: 8),
            _buildSettingsItem(
              context,
              icon: Icons.person_outline,
              title: l10n?.viewProfile ?? 'View Profile',
              onTap: () {
                // Navigate to edit profile if available or just show snackbar
              },
              colors: colors,
            ),
            const SizedBox(height: 16),
            _buildSectionHeader("APPEARANCE", colors),
            const SizedBox(height: 8),
            _buildSettingsItem(
              context,
              icon: Icons.palette_outlined,
              title: "Theme",
              onTap: () => showThemeSelector(context),
              colors: colors,
            ),
            const SizedBox(height: 16),
            _buildSectionHeader("DANGER ZONE", colors),
            const SizedBox(height: 8),
            _buildSettingsItem(
              context,
              icon: Icons.delete_outline,
              title: "Delete Account",
              isDestructive: true,
              onTap: () => _showDeleteConfirmation(context, ref, colors),
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required AppColors colors,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? colors.error.withOpacity(0.1)
                : colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? colors.error : colors.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? colors.error : colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: colors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Account",
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          "Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.",
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteAccount(context, ref);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: colors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      
      if (context.mounted) {
         Navigator.pop(context); // Pop loading
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: $e")),
        );
      }
    }
  }
}
