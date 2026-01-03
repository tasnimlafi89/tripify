import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'app_colors.dart';

class ThemeNotifier extends StateNotifier<AppThemeType> {
  static const _key = 'app_theme';

  ThemeNotifier() : super(AppThemeType.purple) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_key) ?? 0;
    if (themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
      state = AppThemeType.values[themeIndex];
    } else {
      state = AppThemeType.purple;
      await prefs.setInt(_key, state.index);
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, theme.index);
  }

  AppColors get colors => AppTheme.getColors(state);
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

final appColorsProvider = Provider<AppColors>((ref) {
  final themeType = ref.watch(themeProvider);
  return AppTheme.getColors(themeType);
});
