import 'package:flutter/material.dart';

class Hotel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final String currency;
  final List<String> photos;
  final List<HotelFacility> facilities;
  final List<HotelRoom> rooms;
  final String checkInTime;
  final String checkOutTime;
  final bool isFeatured;
  final double discountPercentage;
  final List<String> policies;

  const Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.currency,
    required this.photos,
    required this.facilities,
    required this.rooms,
    required this.checkInTime,
    required this.checkOutTime,
    this.isFeatured = false,
    this.discountPercentage = 0,
    this.policies = const [],
  });

  double get discountedPrice => 
    discountPercentage > 0 
      ? pricePerNight * (1 - discountPercentage / 100) 
      : pricePerNight;

  String get formattedPrice => '$currency${discountedPrice.toStringAsFixed(0)}';
  String get originalPrice => '$currency${pricePerNight.toStringAsFixed(0)}';
}

class HotelFacility {
  final String name;
  final IconData icon;
  final bool isAvailable;

  const HotelFacility({
    required this.name,
    required this.icon,
    this.isAvailable = true,
  });
}

class HotelRoom {
  final String id;
  final String name;
  final String description;
  final double pricePerNight;
  final int maxGuests;
  final double size;
  final List<String> amenities;
  final List<String> photos;
  final bool isAvailable;
  final int availableRooms;

  const HotelRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.maxGuests,
    required this.size,
    required this.amenities,
    required this.photos,
    this.isAvailable = true,
    this.availableRooms = 5,
  });
}

class HotelBooking {
  final String id;
  final Hotel hotel;
  final HotelRoom room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int rooms;
  final GuestInfo guestInfo;
  final PaymentInfo? paymentInfo;
  final BookingStatus status;
  final double totalPrice;
  final DateTime createdAt;

  const HotelBooking({
    required this.id,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.rooms,
    required this.guestInfo,
    this.paymentInfo,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });

  int get nights => checkOut.difference(checkIn).inDays;
}

class GuestInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? specialRequests;

  const GuestInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.specialRequests,
  });
}

class PaymentInfo {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;
  final PaymentMethod method;

  const PaymentInfo({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
    required this.method,
  });

  String get maskedCardNumber => 
    '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
}

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.payment;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.g_mobiledata;
    }
  }
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }
}
