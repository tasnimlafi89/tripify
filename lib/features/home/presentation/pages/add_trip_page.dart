import 'dart:async'; // For Timer
import 'dart:convert';
import 'dart:math';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/home/presentation/pages/trip_planning_page.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/services/location_service.dart';

/// ----------------------------
/// COUNTRY MODEL
/// ----------------------------
/// Represents a country with its name, code, location, and translations.
class CountryData {
  final String name;
  final String code;
  final LatLng location;
  final List<String> capitals;
  final Map<String, String> translations;

  CountryData({
    required this.name,
    required this.code,
    required this.location,
    required this.capitals,
    required this.translations,
  });

  /// Factory method to create a CountryData instance from the REST Countries API JSON.
  factory CountryData.fromApi(Map<String, dynamic> json) {
    // Extract translations
    final Map<String, String> translationsMap = {};
    if (json['translations'] != null) {
      (json['translations'] as Map).forEach((key, value) {
        if (value is Map && value['common'] != null) {
          translationsMap[key] = value['common'].toString();
        }
      });
    }

    return CountryData(
      name: json['name']['common'],
      code: json['cca2'] ?? '',
      location: LatLng(
        (json['latlng'][0] as num).toDouble(),
        (json['latlng'][1] as num).toDouble(),
      ),
      capitals: (json['capital'] as List?)?.map((e) => e.toString()).toList() ?? [],
      translations: translationsMap,
    );
  }

  /// Returns the localized name of the country based on the current context's locale.
  String getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    // Try to find exact locale match (e.g. 'fr')
    if (translations.containsKey(locale)) {
      return translations[locale]!;
    }
    // Fallback to name
    return name;
  }

  /// Returns the emoji flag for the country code.
  String get flag =>
      String.fromCharCodes(code.codeUnits.map((c) => 127397 + c));
}

/// ----------------------------
/// PLACE SEARCH RESULT MODEL
/// ----------------------------
/// Represents a search result from the Nominatim API (city, country, etc.).
class PlaceSearchResult {
  final String name; // e.g. "Paris"
  final String displayName; // Full address
  final LatLng location;
  final String type; // city, country, administrative, etc.
  final String? countryCode;
  final String? countryName; // Full country name from address
  final String? cityName; // City name from address
  final String? stateName; // State/region name from address

  PlaceSearchResult({
    required this.name,
    required this.displayName,
    required this.location,
    required this.type,
    this.countryCode,
    this.countryName,
    this.cityName,
    this.stateName,
  });

  /// Factory method to create a PlaceSearchResult from Nominatim API JSON.
  factory PlaceSearchResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    final resultName = json['name'] as String? ?? json['display_name'].split(',')[0];
    
    // Extract city name from various possible fields (Nominatim uses different fields for different places)
    String? cityName = address?['city'] ?? 
                       address?['town'] ?? 
                       address?['village'] ?? 
                       address?['municipality'] ??
                       address?['county'] ??  // Some places use county
                       address?['suburb'];    // Or suburb
    
    // Extract country name
    String? countryName = address?['country'];
    
    // Extract state/region (for places like Tokyo which are prefectures)
    String? stateName = address?['state'] ?? 
                        address?['region'] ?? 
                        address?['province'] ??
                        address?['prefecture'];
    
    // Get the type
    final type = json['type'] ?? 'unknown';
    final addressType = json['addresstype'] as String?;
    
    // List of known major cities that might be returned as "administrative"
    // These are capitals or major cities that should be treated as cities
    final knownMajorCities = [
      'tokyo', 'paris', 'london', 'new york', 'dubai', 'barcelona', 'rome',
      'berlin', 'madrid', 'amsterdam', 'vienna', 'prague', 'lisbon', 'athens',
      'cairo', 'mumbai', 'delhi', 'bangkok', 'singapore', 'hong kong', 'seoul',
      'beijing', 'shanghai', 'sydney', 'melbourne', 'toronto', 'vancouver',
      'los angeles', 'chicago', 'miami', 'san francisco', 'boston',
      'sousse', 'tunis', 'sfax', 'monastir', 'hammamet', 'djerba',  // Tunisia cities
      'casablanca', 'marrakech', 'fez', 'tangier', 'agadir',  // Morocco cities
      'istanbul', 'ankara', 'izmir', 'antalya',  // Turkey cities
    ];
    
    final lowerName = resultName.toLowerCase();
    final isKnownCity = knownMajorCities.any((city) => 
      lowerName.contains(city) || city.contains(lowerName));
    
    // Determine if this is a country-level result
    // It's a country ONLY if: type is 'country' OR (it's administrative AND not a known city AND no city fields)
    final bool isCountryResult = type == 'country' || 
        (addressType == 'country') ||
        (type == 'administrative' && 
         !isKnownCity && 
         cityName == null && 
         stateName == null &&
         resultName.toLowerCase() == countryName?.toLowerCase());
    
    // If it's a known city or has city-like characteristics, use the name as city
    if (!isCountryResult && cityName == null) {
      // Use the result name as the city name if it looks like a city
      if (isKnownCity || 
          addressType == 'city' || 
          addressType == 'town' ||
          addressType == 'municipality' ||
          type == 'city' ||
          type == 'town') {
        cityName = resultName;
      } else if (stateName != null && resultName.toLowerCase() != countryName?.toLowerCase()) {
        // If there's a state and the name isn't the country, it's probably a city/region
        cityName = resultName;
      }
    }
    
    return PlaceSearchResult(
      name: resultName,
      displayName: json['display_name'],
      location: LatLng(
        double.parse(json['lat']),
        double.parse(json['lon']),
      ),
      type: type,
      countryCode: address?['country_code'],
      countryName: countryName,
      cityName: cityName,
      stateName: stateName,
    );
  }

  /// Returns true if this is a country-level result (not a city)
  bool get isCountryLevel {
    // If we have a cityName set, it's not country-level
    if (cityName != null && cityName!.isNotEmpty) return false;
    
    // If name equals country name, it's country-level
    if (name.toLowerCase() == countryName?.toLowerCase()) return true;
    
    // If type is explicitly 'country', it's country-level
    if (type == 'country') return true;
    
    // Otherwise, if no city but has state, treat as city-level (like Tokyo)
    if (stateName != null && stateName!.isNotEmpty) return false;
    
    // Default: administrative without city info is country-level
    return type == 'administrative';
  }

  /// Returns the emoji flag based on the country code.
  String? get flag {
    if (countryCode == null || countryCode!.length != 2) return null;
    return String.fromCharCodes(
      countryCode!.toUpperCase().codeUnits.map((c) => 127397 + c),
    );
  }
}

/// ----------------------------
/// API SERVICE
/// ----------------------------
/// Handles network requests to fetch country and place data.
class CountryApiService {
  static const _restCountriesUrl = 'https://restcountries.com/v3.1';
  static const _nominatimUrl = 'https://nominatim.openstreetmap.org/search';
  
  List<CountryData>? _allCountries;

  /// Fetches all countries from the REST Countries API.
  Future<List<CountryData>> getAllCountries() async {
    if (_allCountries != null) return _allCountries!;

    try {
      final res = await http.get(Uri.parse('$_restCountriesUrl/all?fields=name,cca2,latlng,capital,translations'));
      if (res.statusCode != 200) return [];

      final List data = jsonDecode(res.body);
      _allCountries = data
          .where((e) => e['latlng'] != null)
          .map((e) => CountryData.fromApi(e))
          .toList();
      
      return _allCountries!;
    } catch (e) {
      return [];
    }
  }

  /// Finds the closest country to the given coordinates.
  Future<CountryData?> getCountryByCoordinates(double lat, double lng) async {
    final countries = await getAllCountries();
    
    // Find closest country by coordinates
    CountryData? closest;
    double minDistance = double.infinity;
    
    for (var country in countries) {
      final distance = _calculateDistance(
        lat, lng,
        country.location.latitude,
        country.location.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closest = country;
      }
    }
    
    return closest;
  }

  /// Haversine formula to calculate distance between two coordinates.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - 
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /// Search for places (cities, countries, etc.) using Nominatim API.
  Future<List<PlaceSearchResult>> searchPlaces(String query, String languageCode) async {
    if (query.length < 2) return [];

    try {
      final uri = Uri.parse(_nominatimUrl).replace(queryParameters: {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '10',
        'accept-language': languageCode,
        'featuretype': 'city', // Prefer cities
      });

      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'TravelAI_App/1.0', // Required by Nominatim
        },
      );

      if (res.statusCode != 200) return [];

      final List data = jsonDecode(res.body);
      return data.map((e) => PlaceSearchResult.fromNominatim(e)).toList();
    } catch (e) {
      debugPrint("Error searching places: $e");
      return [];
    }
  }
}



/// ----------------------------
/// ADD TRIP PAGE
/// ----------------------------
/// The main page for adding a new trip. Displays a map and allows searching for destinations.
class AddTripPage extends ConsumerStatefulWidget {
  const AddTripPage({super.key});

  @override
  ConsumerState<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends ConsumerState<AddTripPage> with TickerProviderStateMixin {
  final _api = CountryApiService();
  final _locationService = LocationService();
  final _mapController = MapController();
  
  CountryData? fromCountry;
  LatLng? _userLocation;
  
  // Changed from CountryData to PlaceSearchResult to support cities
  PlaceSearchResult? toPlace;
  
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _detectCurrentCountry();
  }

  /// Detects the user's current country based on their location.
  Future<void> _detectCurrentCountry() async {
    setState(() => isLoadingLocation = true);
    
    final position = await _locationService.getCurrentLocation();
    
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      final country = await _api.getCountryByCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (mounted) {
        setState(() {
          _userLocation = latLng;
          fromCountry = country;
          isLoadingLocation = false;
        });
        // Move to exact user location
        _animatedMapMove(latLng, 5.0);
      }
    } else {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  /// Animates the map movement to a new location.
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    // Create a controller that will drive the tween animation
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  /// Opens the search bottom sheet for selecting a destination.
  void _openPlaceSearch() async {
    final selected = await showModalBottomSheet<PlaceSearchResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (_) => _PlaceSearchSheet(api: _api),
    );

    if (selected != null) {
      setState(() => toPlace = selected);
      _animatedMapMove(selected.location, 10.0); // Closer zoom for cities
    }
  }

  void _startPlanningTrip(AppColors colors) {
    if (toPlace == null) return;
    
    // Determine city and country names using the new accurate fields
    String? cityName;
    String? countryName;

    // Use the isCountryLevel property which checks properly
    final isCountry = toPlace!.isCountryLevel;

    if (isCountry) {
      // Country-level selection
      cityName = null;
      countryName = toPlace!.countryName ?? toPlace!.name;
    } else {
      // City-level selection - use the cityName from address if available, 
      // otherwise use the result name
      cityName = toPlace!.cityName ?? toPlace!.name;
      
      // Use the countryName from address (most accurate)
      countryName = toPlace!.countryName;
      
      // Fallback: extract from display name if countryName is null
      if (countryName == null || countryName.isEmpty) {
        final parts = toPlace!.displayName.split(',');
        if (parts.length >= 2) {
          countryName = parts.last.trim();
          // If country name is zip code or number, try previous part
          if (RegExp(r'^\d+$').hasMatch(countryName) && parts.length > 2) {
            countryName = parts[parts.length - 2].trim();
          }
        }
      }
      
      // Final fallback
      countryName ??= toPlace!.countryCode?.toUpperCase() ?? "Unknown";
    }

    // Generate data needed for trip (but don't save yet)
    final random = Random();
    final featuredColors = colors.featuredColors;
    final randomColor = featuredColors[random.nextInt(featuredColors.length)];
    
    // Navigate to Planning Page - trip will be saved there if user confirms
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripPlanningPage(
          cityName: cityName ?? "No city selected",
          countryName: countryName ?? "Unknown",
          tripId: null, // No tripId yet - will be created when saved
          destinationName: toPlace!.name,
          latitude: toPlace!.location.latitude,
          longitude: toPlace!.location.longitude,
          tripColor: randomColor,
          isCountryOnly: isCountry,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final isDark = colors.brightness == Brightness.dark;
    
    // Determine map style based on theme
    final mapUrl = isDark 
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          /// ----------------------------
          /// MAP BACKGROUND LAYER
          /// ----------------------------
          /// Displays the interactive map with custom tiles based on the current theme.
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(20, 0),
              initialZoom: 3.0,
              minZoom: 2.0,
            ),
            children: [
              // Map Tiles with Color Tinting
              ColorFiltered(
                colorFilter: isDark
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst) // No tint for dark mode usually needed, or could add slight tint
                    : ColorFilter.mode(colors.primary.withOpacity(0.15), BlendMode.srcATop), // Tint light map with primary color (e.g. purple)
                child: TileLayer(
                  urlTemplate: mapUrl,
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.frontend',
                ),
              ),
              
              MarkerLayer(
                markers: [
                  // Current Location Marker (Exact Position)
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.my_location_rounded,
                              color: colors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              "You",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Destination Marker
                  if (toPlace != null)
                    Marker(
                      point: toPlace!.location,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: colors.error,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          /// ----------------------------
          /// TOP SEARCH BAR (Floating)
          /// ----------------------------
          /// A floating search bar that allows users to search for destinations.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Back Button (Rounded Cube)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16), // Rounded cube
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: colors.primary, // Theme color
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    
                    // Search Input Trigger
                    Expanded(
                      child: GestureDetector(
                        onTap: _openPlaceSearch,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: colors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      toPlace != null 
                                          ? toPlace!.name
                                          : "Where do you want to go?",
                                      style: TextStyle(
                                        color: toPlace != null ? colors.textPrimary : colors.textSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (toPlace != null)
                                      Text(
                                        "Tap to change",
                                        style: TextStyle(
                                          color: colors.textHint,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (toPlace != null)
                                IconButton(
                                  icon: Icon(Icons.close_rounded, color: colors.textHint),
                                  onPressed: () {
                                    setState(() => toPlace = null);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ----------------------------
          /// CONTINUE BUTTON (Floating Bottom)
          /// ----------------------------
          /// Appears when a destination is selected.
          if (toPlace != null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: SafeArea(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _startPlanningTrip(colors);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore_rounded, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            "Start Planning",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ----------------------------
/// PLACE SEARCH BOTTOM SHEET
/// ----------------------------
class _PlaceSearchSheet extends ConsumerStatefulWidget {
  final CountryApiService api;

  const _PlaceSearchSheet({required this.api});

  @override
  ConsumerState<_PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends ConsumerState<_PlaceSearchSheet> {
  final controller = TextEditingController();
  List<PlaceSearchResult> results = [];
  bool isLoading = false;
  
  // Timer for debounce to prevent excessive API calls
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }
  
  /// Performs the search operation.
  void _search(String value) async {
    if (value.length < 2) return;
    
    setState(() => isLoading = true);
    
    final languageCode = Localizations.localeOf(context).languageCode;
    final places = await widget.api.searchPlaces(value, languageCode);
    
    if (mounted) {
      setState(() {
        results = places;
        isLoading = false;
      });
    }
  }

  /// Handles text input changes with debounce logic.
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final isDark = colors.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY:3),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: colors.background.withOpacity(0.3), // Semi-transparent background
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: colors.primary.withOpacity(0.3), width: 1),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textHint.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Search city or country...",
                    hintStyle: TextStyle(color: colors.primary),
                    prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
                    filled: true,
                    fillColor: colors.surfaceVariant.withOpacity(0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
          
              // Results List
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: colors.primary))
                    : results.isEmpty && controller.text.length > 2
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: colors.textHint),
                                const SizedBox(height: 12),
                                Text(
                                  "No places found",
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: results.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final place = results[index];
                              return _buildPlaceItem(place, colors);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single search result item with frosty glass effect.
  Widget _buildPlaceItem(PlaceSearchResult place, AppColors colors) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, place),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.4), // Frosty transparent
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.05), // Subtle glow
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: place.flag != null 
                    ? Center(child: Text(place.flag!, style: const TextStyle(fontSize: 24)))
                    : Icon(
                        Icons.location_city_rounded,
                        color: colors.primary,
                        size: 24,
                      ),
              ),
              title: Text(
                place.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    place.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.map_rounded, 
                        size: 12, 
                        color: colors.textHint
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${place.location.latitude.toStringAsFixed(4)}, ${place.location.longitude.toStringAsFixed(4)}",
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textHint,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
