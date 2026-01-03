
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_colors.dart';

void main() {
  test('AppTheme configuration', () {
    final theme = AppTheme.getThemeData(AppThemeType.purple);
    expect(theme, isNotNull);
    expect(theme.cardTheme.color, AppColors.purple.surface);
  });
}
