import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:frontend/features/home/domain/entities/activity.dart';

class ActivitiesService {
  // Geoapify Places API - Free tier: 3000 requests/day
  // Get your API key from: https://myprojects.geoapify.com/
  static const String _geoapifyKey = '0e7cd71097c74a5c8902e23eb7ad4a0b';
  
  // Foursquare Places API (backup) - Free tier available
  // static const String _foursquareKey = 'YOUR_FOURSQUARE_KEY';
  
  static final ActivitiesService _instance = ActivitiesService._internal();
  factory ActivitiesService() => _instance;
  ActivitiesService._internal();

  /// Search activities by city name - Main entry point
  Future<List<Activity>> searchActivitiesByCity({
    required String cityName,
    required String countryName,
    String? category,
    int limit = 30,
  }) async {
    try {
      // First, geocode the city to get coordinates
      final coords = await _geocodeCity(cityName, countryName);
      
      if (coords != null) {
        return await getActivitiesByLocation(
          latitude: coords['lat']!,
          longitude: coords['lon']!,
          cityName: cityName,
          countryName: countryName,
          category: category,
          limit: limit,
        );
      }
      
      // Fallback to mock data if geocoding fails
      return _generateActivitiesForCity(cityName, countryName);
    } catch (e) {
      print('Error searching activities: $e');
      return _generateActivitiesForCity(cityName, countryName);
    }
  }

  /// Geocode city to get coordinates
  Future<Map<String, double>?> _geocodeCity(String cityName, String countryName) async {
    try {
      final url = 'https://api.geoapify.com/v1/geocode/search?'
          'text=${Uri.encodeComponent('$cityName, $countryName')}'
          '&format=json'
          '&apiKey=$_geoapifyKey';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0];
          return {
            'lat': result['lat'].toDouble(),
            'lon': result['lon'].toDouble(),
          };
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// Get activities near a location using Geoapify Places API
  Future<List<Activity>> getActivitiesByLocation({
    required double latitude,
    required double longitude,
    required String cityName,
    required String countryName,
    String? category,
    int limit = 30,
  }) async {
    try {
      // Categories for Geoapify
      final categories = category != null 
          ? _getCategoryFilter(category)
          : 'tourism.attraction,tourism.sights,entertainment,leisure,sport,catering.restaurant,catering.cafe';
      
      final url = 'https://api.geoapify.com/v2/places?'
          'categories=$categories'
          '&filter=circle:$longitude,$latitude,10000'
          '&limit=$limit'
          '&apiKey=$_geoapifyKey';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List? ?? [];
        
        if (features.isEmpty) {
          return _generateActivitiesForCity(cityName, countryName, lat: latitude, lon: longitude);
        }
        
        final activities = <Activity>[];
        for (var feature in features) {
          final activity = _parseGeoapifyPlace(feature, cityName, countryName);
          if (activity != null) {
            activities.add(activity);
          }
        }
        
        // If we got some results but not many, supplement with mock data
        if (activities.length < 5) {
          activities.addAll(_generateActivitiesForCity(cityName, countryName, lat: latitude, lon: longitude).take(10 - activities.length));
        }
        
        return activities;
      }
      
      return _generateActivitiesForCity(cityName, countryName, lat: latitude, lon: longitude);
    } catch (e) {
      print('Error fetching activities from Geoapify: $e');
      return _generateActivitiesForCity(cityName, countryName, lat: latitude, lon: longitude);
    }
  }

  /// Parse Geoapify place to Activity
  Activity? _parseGeoapifyPlace(Map<String, dynamic> feature, String cityName, String countryName) {
    try {
      final props = feature['properties'] ?? {};
      final geometry = feature['geometry'] ?? {};
      final coords = geometry['coordinates'] as List? ?? [0, 0];
      
      final name = props['name'] ?? props['address_line1'];
      if (name == null || name.toString().isEmpty) return null;
      
      // Determine category from Geoapify categories
      final categories = (props['categories'] as List?)?.cast<String>() ?? [];
      final category = _parseGeoapifyCategory(categories);
      
      // Generate realistic price based on category
      final price = _generatePrice(category);
      
      // Generate rating
      final rating = 3.5 + Random().nextDouble() * 1.5;
      
      // Get image URL based on category
      final imageUrl = _getImageForCategory(category, name.toString());
      
      return Activity(
        id: props['place_id'] ?? 'geo_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        name: name.toString(),
        description: props['formatted'] ?? 'Discover ${name.toString()} in $cityName. A wonderful place to explore and experience local culture.',
        category: category,
        price: price,
        rating: double.parse(rating.toStringAsFixed(1)),
        reviewCount: 50 + Random().nextInt(450),
        imageUrls: [imageUrl],
        latitude: coords[1].toDouble(),
        longitude: coords[0].toDouble(),
        address: props['formatted'] ?? '$cityName, $countryName',
        cityName: cityName,
        countryName: countryName,
        duration: Duration(hours: 1 + Random().nextInt(3)),
        features: _generateFeatures(category),
        requirements: _generateRequirements(category),
        includedItems: _generateIncludedItems(category),
        excludedItems: ['Transportation', 'Personal expenses', 'Gratuities'],
        providerName: '${cityName} ${category.displayName} Tours',
        openingHours: ['Daily: 9:00 AM - 6:00 PM'],
        isAvailable: true,
        maxParticipants: 10 + Random().nextInt(20),
        difficultyLevel: _getDifficultyForCategory(category),
      );
    } catch (e) {
      print('Error parsing place: $e');
      return null;
    }
  }

  /// Parse category from Geoapify categories list
  ActivityCategory _parseGeoapifyCategory(List<String> categories) {
    final joined = categories.join(',').toLowerCase();
    
    if (joined.contains('sport') || joined.contains('climbing') || joined.contains('hiking')) {
      return ActivityCategory.sports;
    } else if (joined.contains('natural') || joined.contains('park') || joined.contains('garden')) {
      return ActivityCategory.nature;
    } else if (joined.contains('museum') || joined.contains('historic') || joined.contains('heritage') || joined.contains('monument')) {
      return ActivityCategory.cultural;
    } else if (joined.contains('restaurant') || joined.contains('cafe') || joined.contains('food') || joined.contains('bar')) {
      return ActivityCategory.foodAndDrink;
    } else if (joined.contains('entertainment') || joined.contains('cinema') || joined.contains('theatre')) {
      return ActivityCategory.entertainment;
    } else if (joined.contains('shop') || joined.contains('mall')) {
      return ActivityCategory.shopping;
    } else if (joined.contains('beach') || joined.contains('spa') || joined.contains('wellness')) {
      return ActivityCategory.relaxation;
    } else if (joined.contains('tourism') || joined.contains('attraction') || joined.contains('sights')) {
      return ActivityCategory.tours;
    } else if (joined.contains('nightclub') || joined.contains('nightlife')) {
      return ActivityCategory.nightlife;
    } else if (joined.contains('adventure') || joined.contains('extreme')) {
      return ActivityCategory.adventure;
    }
    return ActivityCategory.tours;
  }

  /// Get category filter for Geoapify API
  String _getCategoryFilter(String category) {
    switch (category.toLowerCase()) {
      case 'adventure':
        return 'sport,leisure.park,natural';
      case 'relaxation':
        return 'leisure.spa,beach,natural.beach,leisure.park';
      case 'cultural':
        return 'tourism.attraction,tourism.sights,entertainment.museum,building.historic';
      case 'foodanddrink':
      case 'food':
        return 'catering.restaurant,catering.cafe,catering.bar';
      case 'nature':
        return 'natural,leisure.park,tourism.attraction.natural';
      case 'entertainment':
        return 'entertainment,entertainment.cinema,entertainment.theatre';
      case 'sports':
        return 'sport,leisure.sports_centre';
      case 'nightlife':
        return 'entertainment.nightclub,catering.bar,catering.pub';
      case 'shopping':
        return 'commercial.shopping_mall,commercial';
      case 'tours':
        return 'tourism.attraction,tourism.sights,tourism.information';
      default:
        return 'tourism.attraction,tourism.sights,entertainment,leisure';
    }
  }

  /// Generate activities for a city (mock data with real city context)
  List<Activity> _generateActivitiesForCity(String cityName, String countryName, {double? lat, double? lon}) {
    final random = Random();
    final baseLat = lat ?? 40.0 + random.nextDouble() * 20;
    final baseLon = lon ?? -5.0 + random.nextDouble() * 30;
    
    final activities = <Activity>[
      Activity(
        id: 'act_${cityName.hashCode}_1',
        name: '$cityName Walking Tour',
        description: 'Explore the historic streets and hidden gems of $cityName with an expert local guide. Discover the rich history, stunning architecture, and vibrant culture that makes this city unique. Perfect for first-time visitors and history enthusiasts alike.',
        category: ActivityCategory.tours,
        price: 25.0 + random.nextInt(20).toDouble(),
        rating: 4.6 + random.nextDouble() * 0.3,
        reviewCount: 200 + random.nextInt(300),
        imageUrls: [
          'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
        ],
        latitude: baseLat + 0.01,
        longitude: baseLon + 0.01,
        address: 'City Center, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 3),
        features: ['Small groups (max 12)', 'Local expert guide', 'Historical insights', 'Photo opportunities', 'Insider tips'],
        requirements: ['Comfortable walking shoes', 'Weather-appropriate clothing', 'Water bottle'],
        includedItems: ['Professional guide', 'City map', 'Bottled water', 'Audio headset'],
        excludedItems: ['Food and drinks', 'Entrance fees to attractions', 'Gratuities'],
        providerName: '$cityName Walking Tours',
        openingHours: ['Daily: 9:00 AM, 2:00 PM, 5:00 PM'],
        maxParticipants: 12,
        difficultyLevel: 'Easy',
      ),
      Activity(
        id: 'act_${cityName.hashCode}_2',
        name: 'Sunset Kayaking Adventure',
        description: 'Experience the magic of $cityName from the water as you paddle through scenic waterways during golden hour. This unforgettable adventure combines physical activity with breathtaking views, perfect for couples and adventure seekers.',
        category: ActivityCategory.adventure,
        price: 55.0 + random.nextInt(30).toDouble(),
        rating: 4.8 + random.nextDouble() * 0.2,
        reviewCount: 150 + random.nextInt(200),
        imageUrls: [
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          'https://images.unsplash.com/photo-1472745942893-4b9f730c7668?w=800',
        ],
        latitude: baseLat + 0.02,
        longitude: baseLon - 0.01,
        address: 'Marina District, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 2, minutes: 30),
        features: ['Stunning sunset views', 'All equipment provided', 'Photo service available', 'Safety briefing included', 'Waterproof bags provided'],
        requirements: ['Able to swim', 'Minimum age 12', 'Sign liability waiver', 'No experience needed'],
        includedItems: ['Kayak and paddle', 'Life jacket', 'Waterproof bag', 'Professional instructor', 'Safety equipment'],
        excludedItems: ['Transportation to marina', 'Snacks and drinks', 'Photos (optional purchase)'],
        providerName: '$cityName Adventure Sports',
        openingHours: ['Sunset tours daily (time varies by season)'],
        maxParticipants: 10,
        minAge: 12,
        difficultyLevel: 'Moderate',
      ),
      Activity(
        id: 'act_${cityName.hashCode}_3',
        name: 'Luxury Spa & Wellness Day',
        description: 'Indulge in a full day of relaxation at $cityName\'s premier spa. Enjoy therapeutic massages, rejuvenating facials, and access to world-class wellness facilities. The perfect escape from everyday stress.',
        category: ActivityCategory.relaxation,
        price: 120.0 + random.nextInt(80).toDouble(),
        rating: 4.7 + random.nextDouble() * 0.3,
        reviewCount: 180 + random.nextInt(220),
        imageUrls: [
          'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800',
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
        ],
        latitude: baseLat - 0.01,
        longitude: baseLon + 0.02,
        address: 'Wellness Quarter, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 5),
        features: ['Heated indoor pools', 'Steam room & sauna', 'Relaxation lounge', 'Organic products', 'Rooftop terrace'],
        requirements: ['Reservation required 24h in advance', 'Arrive 30 minutes early', 'Age 18+'],
        includedItems: ['60-minute massage', '30-minute facial', 'Robe and slippers', 'Herbal tea service', 'Locker and amenities'],
        excludedItems: ['Additional treatments', 'Lunch (available for purchase)', 'Gratuities'],
        providerName: '$cityName Wellness Spa',
        openingHours: ['Mon-Sat: 9:00 AM - 9:00 PM', 'Sun: 10:00 AM - 7:00 PM'],
        maxParticipants: 1,
        minAge: 18,
      ),
      Activity(
        id: 'act_${cityName.hashCode}_4',
        name: 'Food & Wine Tasting Tour',
        description: 'Embark on a culinary journey through $cityName! Sample authentic local cuisine, artisan cheeses, and regional wines at carefully selected venues. Meet local chefs and learn about the culinary traditions that define this region.',
        category: ActivityCategory.foodAndDrink,
        price: 75.0 + random.nextInt(35).toDouble(),
        rating: 4.9,
        reviewCount: 350 + random.nextInt(200),
        imageUrls: [
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
          'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=800',
        ],
        latitude: baseLat,
        longitude: baseLon,
        address: 'Old Town, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 4),
        features: ['8+ food tastings', 'Wine pairings', 'Local expert guide', 'Small group experience', 'Hidden gem locations'],
        requirements: ['Age 18+ for alcohol', 'Inform of dietary restrictions/allergies', 'Comfortable walking shoes'],
        includedItems: ['All food tastings', 'Wine and beverage samples', 'Expert culinary guide', 'Recipe booklet', 'Market discount vouchers'],
        excludedItems: ['Additional drinks', 'Transportation', 'Gratuities'],
        providerName: 'Taste of $cityName',
        openingHours: ['Tue-Sun: 11:00 AM & 5:00 PM tours'],
        maxParticipants: 10,
        minAge: 18,
      ),
      Activity(
        id: 'act_${cityName.hashCode}_5',
        name: 'Museum & Art Gallery Pass',
        description: 'Unlock access to $cityName\'s finest museums and galleries with this premium pass. Skip the lines and explore world-class art, history, and culture at your own pace. Valid for 48 hours.',
        category: ActivityCategory.cultural,
        price: 35.0 + random.nextInt(25).toDouble(),
        rating: 4.5 + random.nextDouble() * 0.4,
        reviewCount: 500 + random.nextInt(300),
        imageUrls: [
          'https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=800',
          'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=800',
        ],
        latitude: baseLat - 0.005,
        longitude: baseLon - 0.005,
        address: 'Museum District, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 48),
        features: ['Skip-the-line access', '5+ top museums', 'Audio guide app included', 'Valid for 48 hours', 'Digital ticket'],
        requirements: ['Valid ID required', 'Download app for audio guide'],
        includedItems: ['All museum entries', 'Skip-the-line privileges', 'Audio guide app', 'Digital city map', 'Exclusive discounts'],
        excludedItems: ['Transportation', 'Special exhibitions (some)', 'Food and drinks'],
        providerName: '$cityName Culture Pass',
        openingHours: ['Museums typically: 10:00 AM - 6:00 PM'],
      ),
      Activity(
        id: 'act_${cityName.hashCode}_6',
        name: 'Mountain Hiking Expedition',
        description: 'Challenge yourself with a guided hiking expedition in the stunning landscapes near $cityName. Breathtaking panoramic views, pristine nature, and the chance to spot local wildlife await. Suitable for intermediate hikers.',
        category: ActivityCategory.nature,
        price: 65.0 + random.nextInt(40).toDouble(),
        rating: 4.8 + random.nextDouble() * 0.2,
        reviewCount: 120 + random.nextInt(180),
        imageUrls: [
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
          'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=800',
        ],
        latitude: baseLat + 0.05,
        longitude: baseLon + 0.03,
        address: 'Mountain Region, $cityName Area',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 7),
        features: ['Scenic mountain trails', 'Wildlife spotting', 'Picnic lunch included', 'Professional photos', 'Small groups'],
        requirements: ['Good fitness level required', 'Hiking boots mandatory', 'Bring backpack with water', 'Sun protection'],
        includedItems: ['Expert mountain guide', 'Gourmet picnic lunch', 'Hiking poles (if needed)', 'First aid kit', 'Trail snacks'],
        excludedItems: ['Transportation to trailhead', 'Personal hiking gear', 'Travel insurance'],
        providerName: '$cityName Hiking Adventures',
        openingHours: ['Daily departure: 7:00 AM'],
        maxParticipants: 8,
        minAge: 14,
        difficultyLevel: 'Challenging',
      ),
      Activity(
        id: 'act_${cityName.hashCode}_7',
        name: 'Nightlife & Club Tour',
        description: 'Experience $cityName after dark! This exclusive nightlife tour takes you to the hottest clubs, rooftop bars, and hidden speakeasies. VIP entry, welcome drinks, and an unforgettable night guaranteed.',
        category: ActivityCategory.nightlife,
        price: 45.0 + random.nextInt(35).toDouble(),
        rating: 4.6 + random.nextDouble() * 0.3,
        reviewCount: 280 + random.nextInt(220),
        imageUrls: [
          'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?w=800',
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
        ],
        latitude: baseLat - 0.008,
        longitude: baseLon + 0.012,
        address: 'Entertainment District, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 5),
        features: ['VIP club entry', '3 venue stops', 'Welcome drinks', 'Local nightlife expert', 'Skip all queues'],
        requirements: ['Age 21+', 'Valid ID required', 'Smart casual dress code'],
        includedItems: ['VIP entry to all venues', 'Welcome drink at each stop', 'Nightlife guide', 'Club discounts'],
        excludedItems: ['Additional drinks', 'Late night transportation', 'Coat check fees'],
        providerName: '$cityName Nightlife Tours',
        openingHours: ['Thu-Sat: 10:00 PM start'],
        maxParticipants: 15,
        minAge: 21,
      ),
      Activity(
        id: 'act_${cityName.hashCode}_8',
        name: 'Local Market Shopping Experience',
        description: 'Discover the authentic side of $cityName at its vibrant local markets. Learn to bargain like a local, sample street food, and find unique souvenirs. A cultural immersion into daily life.',
        category: ActivityCategory.shopping,
        price: 30.0 + random.nextInt(20).toDouble(),
        rating: 4.7 + random.nextDouble() * 0.2,
        reviewCount: 190 + random.nextInt(160),
        imageUrls: [
          'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800',
          'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?w=800',
        ],
        latitude: baseLat + 0.003,
        longitude: baseLon - 0.007,
        address: 'Market District, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 3),
        features: ['3 unique markets', 'Street food tastings', 'Bargaining tips', 'Artisan workshops', 'Local guide'],
        requirements: ['Comfortable shoes', 'Bring cash for purchases'],
        includedItems: ['Expert market guide', 'Street food samples', 'Shopping tips booklet', 'Artisan contact list'],
        excludedItems: ['Personal purchases', 'Transportation', 'Additional food'],
        providerName: '$cityName Market Tours',
        openingHours: ['Daily: 9:00 AM & 3:00 PM'],
        maxParticipants: 12,
      ),
      Activity(
        id: 'act_${cityName.hashCode}_9',
        name: 'Cooking Class with Local Chef',
        description: 'Learn to cook authentic local dishes in this hands-on cooking class. A professional chef will guide you through traditional recipes, and you\'ll enjoy the meal you create. Take home recipes to recreate at home.',
        category: ActivityCategory.foodAndDrink,
        price: 85.0 + random.nextInt(45).toDouble(),
        rating: 4.9,
        reviewCount: 420 + random.nextInt(180),
        imageUrls: [
          'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800',
          'https://images.unsplash.com/photo-1507048331197-7d4ac70811cf?w=800',
        ],
        latitude: baseLat - 0.015,
        longitude: baseLon + 0.008,
        address: 'Culinary District, $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 4),
        features: ['Hands-on cooking', 'Professional chef instructor', 'Market visit included', 'Wine pairing', 'Recipe cards'],
        requirements: ['No experience needed', 'Inform of allergies', 'Age 12+ welcome'],
        includedItems: ['All ingredients', 'Wine with meal', 'Professional instruction', 'Recipe booklet', 'Apron to keep'],
        excludedItems: ['Transportation', 'Additional drinks'],
        providerName: '$cityName Cooking School',
        openingHours: ['Tue-Sun: 10:00 AM & 4:00 PM classes'],
        maxParticipants: 8,
        minAge: 12,
      ),
      Activity(
        id: 'act_${cityName.hashCode}_10',
        name: 'Bike Tour Around the City',
        description: 'See more of $cityName on two wheels! This guided bike tour covers major landmarks, scenic routes, and local neighborhoods that most tourists miss. Bikes, helmets, and snacks included.',
        category: ActivityCategory.sports,
        price: 35.0 + random.nextInt(25).toDouble(),
        rating: 4.7 + random.nextDouble() * 0.2,
        reviewCount: 310 + random.nextInt(190),
        imageUrls: [
          'https://images.unsplash.com/photo-1541625602330-2277a4c46182?w=800',
          'https://images.unsplash.com/photo-1505705694340-019e1e335916?w=800',
        ],
        latitude: baseLat + 0.007,
        longitude: baseLon - 0.003,
        address: 'Central $cityName',
        cityName: cityName,
        countryName: countryName,
        duration: const Duration(hours: 3, minutes: 30),
        features: ['Quality bikes provided', 'Scenic routes', 'Photo stops', 'Local guide', 'Helmet & lock included'],
        requirements: ['Able to ride a bike', 'Comfortable with city cycling', 'Age 12+'],
        includedItems: ['Bike rental', 'Helmet', 'Guide', 'Water bottle', 'Energy snacks'],
        excludedItems: ['Meals', 'Personal expenses'],
        providerName: '$cityName Bike Tours',
        openingHours: ['Daily: 9:30 AM, 2:00 PM'],
        maxParticipants: 14,
        minAge: 12,
        difficultyLevel: 'Easy to Moderate',
      ),
    ];
    
    // Shuffle to provide variety
    activities.shuffle();
    return activities;
  }

  /// Generate price based on category
  double _generatePrice(ActivityCategory category) {
    final random = Random();
    switch (category) {
      case ActivityCategory.relaxation:
        return 80.0 + random.nextInt(120).toDouble();
      case ActivityCategory.adventure:
        return 50.0 + random.nextInt(60).toDouble();
      case ActivityCategory.foodAndDrink:
        return 40.0 + random.nextInt(50).toDouble();
      case ActivityCategory.cultural:
        return 20.0 + random.nextInt(40).toDouble();
      case ActivityCategory.tours:
        return 25.0 + random.nextInt(35).toDouble();
      case ActivityCategory.nightlife:
        return 30.0 + random.nextInt(40).toDouble();
      case ActivityCategory.nature:
        return 40.0 + random.nextInt(50).toDouble();
      case ActivityCategory.sports:
        return 35.0 + random.nextInt(45).toDouble();
      case ActivityCategory.shopping:
        return 15.0 + random.nextInt(25).toDouble();
      case ActivityCategory.entertainment:
        return 25.0 + random.nextInt(35).toDouble();
    }
  }

  /// Get image URL for category
  String _getImageForCategory(ActivityCategory category, String name) {
    switch (category) {
      case ActivityCategory.adventure:
        return 'https://images.unsplash.com/photo-1533692328991-08159ff19fca?w=800';
      case ActivityCategory.relaxation:
        return 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800';
      case ActivityCategory.cultural:
        return 'https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=800';
      case ActivityCategory.foodAndDrink:
        return 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800';
      case ActivityCategory.nature:
        return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800';
      case ActivityCategory.entertainment:
        return 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800';
      case ActivityCategory.sports:
        return 'https://images.unsplash.com/photo-1461896836934- voices?w=800';
      case ActivityCategory.nightlife:
        return 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?w=800';
      case ActivityCategory.shopping:
        return 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800';
      case ActivityCategory.tours:
        return 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800';
    }
  }

  /// Generate features for category
  List<String> _generateFeatures(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.cultural:
        return ['Expert guide', 'Historical insights', 'Skip-the-line', 'Audio guide'];
      case ActivityCategory.adventure:
        return ['Safety equipment', 'Professional instructor', 'Photo opportunities', 'All skill levels'];
      case ActivityCategory.relaxation:
        return ['Premium facilities', 'Organic products', 'Relaxation areas', 'Professional staff'];
      case ActivityCategory.foodAndDrink:
        return ['Local specialties', 'Wine pairing', 'Small group', 'Recipe cards'];
      case ActivityCategory.nature:
        return ['Scenic views', 'Wildlife spotting', 'Expert naturalist', 'Eco-friendly'];
      default:
        return ['Local expert guide', 'Small groups', 'Authentic experience', 'Memorable moments'];
    }
  }

  /// Generate requirements for category
  List<String> _generateRequirements(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.adventure:
      case ActivityCategory.sports:
        return ['Good physical condition', 'Comfortable clothing', 'Closed-toe shoes'];
      case ActivityCategory.nature:
        return ['Hiking shoes recommended', 'Weather-appropriate clothing', 'Water bottle'];
      case ActivityCategory.nightlife:
        return ['Age 21+', 'Valid ID', 'Smart casual attire'];
      case ActivityCategory.foodAndDrink:
        return ['Inform of dietary restrictions', 'Comfortable walking shoes'];
      default:
        return ['Comfortable shoes', 'Weather-appropriate clothing'];
    }
  }

  /// Generate included items for category
  List<String> _generateIncludedItems(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.adventure:
        return ['All equipment', 'Safety briefing', 'Insurance', 'Instructor'];
      case ActivityCategory.relaxation:
        return ['Treatment', 'Robes & slippers', 'Amenities', 'Refreshments'];
      case ActivityCategory.foodAndDrink:
        return ['Food tastings', 'Beverages', 'Guide', 'Recipes'];
      case ActivityCategory.tours:
        return ['Professional guide', 'Entry tickets', 'Audio guide', 'Map'];
      default:
        return ['Professional guide', 'Entrance fees', 'Bottled water'];
    }
  }

  /// Get difficulty level for category
  String _getDifficultyForCategory(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.adventure:
      case ActivityCategory.sports:
        return 'Moderate';
      case ActivityCategory.nature:
        return 'Moderate to Challenging';
      case ActivityCategory.relaxation:
        return 'Easy';
      default:
        return 'Easy';
    }
  }

  /// Add a comment to an activity
  Future<bool> addComment({
    required String activityId,
    required String userId,
    required String userName,
    required String comment,
    double? rating,
  }) async {
    // In a real app, this would POST to your backend
    return true;
  }

  /// Book an activity
  Future<ActivityBooking?> bookActivity({
    required String activityId,
    required String userId,
    required DateTime activityDate,
    required int numberOfParticipants,
    required double totalPrice,
    String? specialRequests,
  }) async {
    // In a real app, this would POST to your backend
    return ActivityBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      activityId: activityId,
      userId: userId,
      bookingDate: DateTime.now(),
      activityDate: activityDate,
      numberOfParticipants: numberOfParticipants,
      totalPrice: totalPrice,
      status: 'confirmed',
      specialRequests: specialRequests,
    );
  }
}
