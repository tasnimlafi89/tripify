import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final colors = ref.watch(appColorsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Theme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: AppThemeType.values.map((theme) {
              final themeColors = AppTheme.getColors(theme);
              final isSelected = currentTheme == theme;
              return GestureDetector(
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(theme);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 70,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? themeColors.primary : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(13),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeColors.primary,
                                themeColors.primaryLight,
                              ],
                            ),
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: themeColors.surface,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(13),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getThemeName(theme),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: themeColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getThemeName(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.purple:
        return 'Purple';
      case AppThemeType.blue:
        return 'Blue';
      case AppThemeType.green:
        return 'Green';
      case AppThemeType.yellow:
        return 'Yellow';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.darkBlue:
        return 'Dark Blue';
      case AppThemeType.darkGreen:
        return 'Dark Green';
      case AppThemeType.darkYellow:
        return 'Dark Yellow';
    }
  }
}

void showThemeSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const ThemeSelector(),
  );
}
