import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/auth/presentation/pages/sign_in_page.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final onboardingSeen = await OnboardingStorage.isSeen();
  runApp(
    ProviderScope(
      child: MyApp(onboardingSeen: onboardingSeen),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool onboardingSeen;

  const MyApp({super.key, required this.onboardingSeen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Travel Planner",
      theme: AppTheme.getThemeData(themeType),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      home: onboardingSeen
          ? SignInPage()
          : const OnboardingPage(),
    );
  }
}
