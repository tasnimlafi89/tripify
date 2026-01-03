import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/presentation/pages/activities_list_page.dart';

class ActivitiesPage extends ConsumerStatefulWidget {
  final String? cityName;
  final String? countryName;
  final double? latitude;
  final double? longitude;

  const ActivitiesPage({
    super.key,
    this.cityName,
    this.countryName,
    this.latitude,
    this.longitude,
  });

  @override
  ConsumerState<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends ConsumerState<ActivitiesPage> {
  @override
  void initState() {
    super.initState();
    // If we have valid city info, navigate directly to the activities list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasValidCity = widget.cityName != null && 
          widget.cityName!.isNotEmpty && 
          widget.cityName != "No city selected";
      final hasValidCountry = widget.countryName != null && 
          widget.countryName!.isNotEmpty;
      
      if (hasValidCity || hasValidCountry) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ActivitiesListPage(
              cityName: hasValidCity ? widget.cityName! : widget.countryName!,
              countryName: widget.countryName ?? '',
              latitude: widget.latitude,
              longitude: widget.longitude,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);

    // If no city info, show a placeholder to enter destination
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Activities",
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.featuredOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_activity_rounded,
                size: 80,
                color: colors.featuredOrange,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Discover Activities",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Please access activities from your trip planning page to see activities available at your destination.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Go Back"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.featuredOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
