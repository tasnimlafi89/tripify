import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/health_service.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'sign_in_page.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 900;

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, String>> _getSlides(AppLocalizations l10n) => [
        {
          "image": "assets/slide1.png",
          "title": l10n.onboardingTitle1,
          "description": l10n.onboardingDesc1,
        },
        {
          "image": "assets/slide2.png",
          "title": l10n.onboardingTitle2,
          "description": l10n.onboardingDesc2,
        },
        {
          "image": "assets/slide3.png",
          "title": l10n.onboardingTitle3,
          "description": l10n.onboardingDesc3,
        },
      ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
    _checkBackend();
  }

  void _navigateToSignIn() async {
    await OnboardingStorage.markSeen();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignInPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkBackend() async {
    final isUp = await HealthService.checkBackend();

    if (!isUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Backend is not reachable"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);

    if (isDesktop(context)) {
      return _buildDesktopLayout(colors, l10n, slides);
    } else {
      return _buildMobileLayout(colors, l10n, slides);
    }
  }

  Widget _buildDesktopLayout(
      dynamic colors, AppLocalizations l10n, List<Map<String, String>> slides) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: colors.backgroundGradient,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primaryLight, colors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.travel_explore,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "TravelPlanner",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [colors.primaryLight, colors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primaryLight.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _navigateToSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.getStarted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [colors.primaryDark, colors.primary],
                              ).createShader(bounds),
                              child: Text(
                                "Plan Your Perfect Journey",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth > 1200 ? 48 : 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "AI-powered travel planning that makes your dream vacation a reality",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: colors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: slides.asMap().entries.map((entry) {
                              final index = entry.key;
                              final slide = entry.value;
                              return Expanded(
                                child: AnimatedBuilder(
                                  animation: _animController,
                                  builder: (_, child) {
                                    return Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: FractionalTranslation(
                                        translation: Offset(
                                            0, _slideAnimation.value.dy * (index + 1) * 0.5),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildFeatureCard(
                                    colors,
                                    slide["image"]!,
                                    slide["title"]!,
                                    slide["description"]!,
                                    screenHeight,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primaryLight.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(dynamic colors, String image, String title,
      String description, double screenHeight) {
    final imageSize = screenHeight * 0.22;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.primaryLight.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primaryLight.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colors.primaryLight.withOpacity(0.15),
                  colors.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Image.asset(
              image,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 28),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [colors.primaryDark, colors.primary],
            ).createShader(bounds),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      dynamic colors, AppLocalizations l10n, List<Map<String, String>> slides) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;

    final imageSize = isVerySmallScreen
        ? screenWidth * 0.45
        : isSmallScreen
            ? screenWidth * 0.5
            : screenWidth * 0.65;

    final titleFontSize = isVerySmallScreen
        ? 22.0
        : isSmallScreen
            ? 26.0
            : 32.0;

    final descFontSize = isVerySmallScreen
        ? 13.0
        : isSmallScreen
            ? 14.0
            : 16.0;

    final spacing = isVerySmallScreen
        ? 16.0
        : isSmallScreen
            ? 24.0
            : 40.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: colors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _currentIndex != slides.length - 1
                      ? TextButton(
                          onPressed: _navigateToSignIn,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: colors.primaryLight.withOpacity(0.5)),
                            ),
                          ),
                          child: Text(
                            l10n.skip,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox(height: 40),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return AnimatedBuilder(
                      animation: _animController,
                      builder: (_, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: FractionalTranslation(
                            translation: _slideAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.primaryLight.withOpacity(0.2),
                                      colors.secondary.withOpacity(0.15),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          colors.primaryLight.withOpacity(0.2),
                                      blurRadius: isSmallScreen ? 20 : 40,
                                      spreadRadius: isSmallScreen ? 8 : 15,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  slides[index]["image"]!,
                                  width: imageSize,
                                  height: imageSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: spacing),

                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    colors.primaryDark,
                                    colors.primary,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  slides[index]["title"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 20),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  slides[index]["description"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: descFontSize,
                                    color: colors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(
                    24, isSmallScreen ? 16 : 24, 24, isSmallScreen ? 20 : 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: _currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _currentIndex == index
                                ? LinearGradient(
                                    colors: [
                                      colors.primaryLight,
                                      colors.secondary,
                                    ],
                                  )
                                : null,
                            color: _currentIndex == index
                                ? null
                                : colors.primaryLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 32),

                    Container(
                      width: double.infinity,
                      height: isSmallScreen ? 50 : 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            colors.primaryLight,
                            colors.secondary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primaryLight.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentIndex == slides.length - 1) {
                            _navigateToSignIn();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentIndex == slides.length - 1
                                  ? l10n.getStarted
                                  : l10n.next,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentIndex == slides.length - 1
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
