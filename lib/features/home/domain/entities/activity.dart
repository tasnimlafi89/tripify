import 'package:flutter/material.dart';

enum ActivityCategory {
  adventure,
  relaxation,
  cultural,
  foodAndDrink,
  nature,
  entertainment,
  sports,
  nightlife,
  shopping,
  tours,
}

extension ActivityCategoryExtension on ActivityCategory {
  String get displayName {
    switch (this) {
      case ActivityCategory.adventure:
        return 'Adventure';
      case ActivityCategory.relaxation:
        return 'Relaxation';
      case ActivityCategory.cultural:
        return 'Cultural';
      case ActivityCategory.foodAndDrink:
        return 'Food & Drink';
      case ActivityCategory.nature:
        return 'Nature';
      case ActivityCategory.entertainment:
        return 'Entertainment';
      case ActivityCategory.sports:
        return 'Sports';
      case ActivityCategory.nightlife:
        return 'Nightlife';
      case ActivityCategory.shopping:
        return 'Shopping';
      case ActivityCategory.tours:
        return 'Tours';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityCategory.adventure:
        return Icons.terrain_rounded;
      case ActivityCategory.relaxation:
        return Icons.spa_rounded;
      case ActivityCategory.cultural:
        return Icons.museum_rounded;
      case ActivityCategory.foodAndDrink:
        return Icons.restaurant_rounded;
      case ActivityCategory.nature:
        return Icons.park_rounded;
      case ActivityCategory.entertainment:
        return Icons.theater_comedy_rounded;
      case ActivityCategory.sports:
        return Icons.sports_soccer_rounded;
      case ActivityCategory.nightlife:
        return Icons.nightlife_rounded;
      case ActivityCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ActivityCategory.tours:
        return Icons.tour_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ActivityCategory.adventure:
        return Colors.orange;
      case ActivityCategory.relaxation:
        return Colors.teal;
      case ActivityCategory.cultural:
        return Colors.purple;
      case ActivityCategory.foodAndDrink:
        return Colors.red;
      case ActivityCategory.nature:
        return Colors.green;
      case ActivityCategory.entertainment:
        return Colors.pink;
      case ActivityCategory.sports:
        return Colors.blue;
      case ActivityCategory.nightlife:
        return Colors.indigo;
      case ActivityCategory.shopping:
        return Colors.amber;
      case ActivityCategory.tours:
        return Colors.cyan;
    }
  }
}

class ActivityComment {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String comment;
  final DateTime createdAt;
  final double? rating;

  ActivityComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.comment,
    required this.createdAt,
    this.rating,
  });

  factory ActivityComment.fromJson(Map<String, dynamic> json) {
    return ActivityComment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatar: json['userAvatar'],
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
        'rating': rating,
      };
}

class Activity {
  final String id;
  final String name;
  final String description;
  final ActivityCategory category;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final String address;
  final String cityName;
  final String countryName;
  final Duration duration;
  final List<String> features;
  final List<String> requirements;
  final List<String> includedItems;
  final List<String> excludedItems;
  final String? providerName;
  final String? providerPhone;
  final String? providerEmail;
  final String? websiteUrl;
  final List<String> openingHours;
  final bool isAvailable;
  final int? maxParticipants;
  final int? minAge;
  final String? difficultyLevel;
  final List<ActivityComment> comments;
  final bool isFavorite;
  final DateTime? createdAt;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.currency = 'USD',
    required this.rating,
    this.reviewCount = 0,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.cityName,
    required this.countryName,
    required this.duration,
    this.features = const [],
    this.requirements = const [],
    this.includedItems = const [],
    this.excludedItems = const [],
    this.providerName,
    this.providerPhone,
    this.providerEmail,
    this.websiteUrl,
    this.openingHours = const [],
    this.isAvailable = true,
    this.maxParticipants,
    this.minAge,
    this.difficultyLevel,
    this.comments = const [],
    this.isFavorite = false,
    this.createdAt,
  });

  Activity copyWith({
    String? id,
    String? name,
    String? description,
    ActivityCategory? category,
    double? price,
    String? currency,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    String? address,
    String? cityName,
    String? countryName,
    Duration? duration,
    List<String>? features,
    List<String>? requirements,
    List<String>? includedItems,
    List<String>? excludedItems,
    String? providerName,
    String? providerPhone,
    String? providerEmail,
    String? websiteUrl,
    List<String>? openingHours,
    bool? isAvailable,
    int? maxParticipants,
    int? minAge,
    String? difficultyLevel,
    List<ActivityComment>? comments,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      duration: duration ?? this.duration,
      features: features ?? this.features,
      requirements: requirements ?? this.requirements,
      includedItems: includedItems ?? this.includedItems,
      excludedItems: excludedItems ?? this.excludedItems,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerEmail: providerEmail ?? this.providerEmail,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      openingHours: openingHours ?? this.openingHours,
      isAvailable: isAvailable ?? this.isAvailable,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minAge: minAge ?? this.minAge,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      comments: comments ?? this.comments,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? json['xid'] ?? '',
      name: json['name'] ?? 'Unknown Activity',
      description: json['description'] ?? json['wikipedia_extracts']?['text'] ?? '',
      category: _parseCategory(json['kinds'] ?? json['category'] ?? ''),
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      rating: (json['rating'] ?? json['rate'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? json['reviews'] ?? 0,
      imageUrls: _parseImageUrls(json),
      latitude: (json['latitude'] ?? json['point']?['lat'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? json['point']?['lon'] ?? 0).toDouble(),
      address: json['address'] ?? json['address_line'] ?? '',
      cityName: json['cityName'] ?? json['city'] ?? '',
      countryName: json['countryName'] ?? json['country'] ?? '',
      duration: Duration(minutes: json['durationMinutes'] ?? 60),
      features: List<String>.from(json['features'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      includedItems: List<String>.from(json['includedItems'] ?? []),
      excludedItems: List<String>.from(json['excludedItems'] ?? []),
      providerName: json['providerName'],
      providerPhone: json['providerPhone'],
      providerEmail: json['providerEmail'],
      websiteUrl: json['websiteUrl'] ?? json['url'],
      openingHours: List<String>.from(json['openingHours'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      maxParticipants: json['maxParticipants'],
      minAge: json['minAge'],
      difficultyLevel: json['difficultyLevel'],
      comments: (json['comments'] as List?)
              ?.map((c) => ActivityComment.fromJson(c))
              .toList() ??
          [],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  static ActivityCategory _parseCategory(String kinds) {
    final lowerKinds = kinds.toLowerCase();
    if (lowerKinds.contains('sport') || lowerKinds.contains('climbing')) {
      return ActivityCategory.sports;
    } else if (lowerKinds.contains('natural') || lowerKinds.contains('nature')) {
      return ActivityCategory.nature;
    } else if (lowerKinds.contains('cultural') || lowerKinds.contains('museum') || lowerKinds.contains('historic')) {
      return ActivityCategory.cultural;
    } else if (lowerKinds.contains('food') || lowerKinds.contains('restaurant') || lowerKinds.contains('cafe')) {
      return ActivityCategory.foodAndDrink;
    } else if (lowerKinds.contains('amusement') || lowerKinds.contains('entertainment')) {
      return ActivityCategory.entertainment;
    } else if (lowerKinds.contains('shop')) {
      return ActivityCategory.shopping;
    } else if (lowerKinds.contains('adventure') || lowerKinds.contains('extreme')) {
      return ActivityCategory.adventure;
    } else if (lowerKinds.contains('spa') || lowerKinds.contains('relax') || lowerKinds.contains('beach')) {
      return ActivityCategory.relaxation;
    } else if (lowerKinds.contains('tour')) {
      return ActivityCategory.tours;
    }
    return ActivityCategory.tours;
  }

  static List<String> _parseImageUrls(Map<String, dynamic> json) {
    if (json['imageUrls'] != null) {
      return List<String>.from(json['imageUrls']);
    }
    if (json['preview']?['source'] != null) {
      return [json['preview']['source']];
    }
    if (json['image'] != null) {
      return [json['image']];
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category.name,
        'price': price,
        'currency': currency,
        'rating': rating,
        'reviewCount': reviewCount,
        'imageUrls': imageUrls,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'cityName': cityName,
        'countryName': countryName,
        'durationMinutes': duration.inMinutes,
        'features': features,
        'requirements': requirements,
        'includedItems': includedItems,
        'excludedItems': excludedItems,
        'providerName': providerName,
        'providerPhone': providerPhone,
        'providerEmail': providerEmail,
        'websiteUrl': websiteUrl,
        'openingHours': openingHours,
        'isAvailable': isAvailable,
        'maxParticipants': maxParticipants,
        'minAge': minAge,
        'difficultyLevel': difficultyLevel,
        'comments': comments.map((c) => c.toJson()).toList(),
        'isFavorite': isFavorite,
        'createdAt': createdAt?.toIso8601String(),
      };

  String get formattedPrice => price == 0 ? 'Free' : '\$${price.toStringAsFixed(2)}';
  
  String get formattedDuration {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

class ActivityBooking {
  final String id;
  final String activityId;
  final String userId;
  final DateTime bookingDate;
  final DateTime activityDate;
  final int numberOfParticipants;
  final double totalPrice;
  final String status;
  final String? specialRequests;
  final Map<String, String> participantDetails;

  ActivityBooking({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.bookingDate,
    required this.activityDate,
    required this.numberOfParticipants,
    required this.totalPrice,
    this.status = 'pending',
    this.specialRequests,
    this.participantDetails = const {},
  });

  factory ActivityBooking.fromJson(Map<String, dynamic> json) {
    return ActivityBooking(
      id: json['id'] ?? '',
      activityId: json['activityId'] ?? '',
      userId: json['userId'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      activityDate: DateTime.parse(json['activityDate']),
      numberOfParticipants: json['numberOfParticipants'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      specialRequests: json['specialRequests'],
      participantDetails: Map<String, String>.from(json['participantDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'userId': userId,
        'bookingDate': bookingDate.toIso8601String(),
        'activityDate': activityDate.toIso8601String(),
        'numberOfParticipants': numberOfParticipants,
        'totalPrice': totalPrice,
        'status': status,
        'specialRequests': specialRequests,
        'participantDetails': participantDetails,
      };
}
